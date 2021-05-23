use std::rc::Rc;

use gtk::{
    prelude::DialogExtManual, DialogExt, FileChooserDialogBuilder, FileChooserExt, GtkWindowExt,
    Window,
};
use nativeshell::{
    shell::Context,
};

use super::FileOpenRequest;

pub(super) fn open_file_dialog<F>(
    win: Window,
    context: Rc<Context>,
    _request: FileOpenRequest,
    reply: F,
) where
    F: FnOnce(Option<String>) + 'static,
{
    let dialog = FileChooserDialogBuilder::new()
        .transient_for(&win)
        .modal(true)
        .action(gtk::FileChooserAction::Open)
        .build();

    dialog.add_buttons(&[
        ("Open", gtk::ResponseType::Ok),
        ("Cancel", gtk::ResponseType::Cancel),
    ]);

    // Platform messages will be processed while dialog is running so
    // make sure it is cheduled on next run loop turn
    context
        .run_loop
        .borrow()
        .schedule_now(move || {
            let res = dialog.run();
            let res = match res {
                gtk::ResponseType::Ok => {
                    let path = dialog.get_filename();
                    path.map(|p| p.to_string_lossy().into())
                }
                _ => None::<String>,
            };
            dialog.close();
            reply(res);
        })
        .detach();
}
