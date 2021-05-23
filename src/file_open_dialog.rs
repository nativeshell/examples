use std::{
    cell::RefCell,
    rc::{Rc, Weak},
};

pub use nativeshell::{
    codec::{value::from_value, MethodCall, MethodCallReply, Value},
    shell::{Context, WindowHandle},
};

pub struct FileOpenDialogService {
    context: Rc<Context>,
    weak_self: RefCell<Weak<FileOpenDialogService>>,
}

#[derive(serde::Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
struct FileOpenRequest {
    parent_window: WindowHandle,
}

#[cfg(target_os = "macos")]
#[path = "file_open_dialog_mac.rs"]
mod platform;

#[cfg(target_os = "windows")]
#[path = "file_open_dialog_win.rs"]
mod platform;

#[cfg(target_os = "linux")]
#[path = "file_open_dialog_linux.rs"]
mod platform;

impl FileOpenDialogService {
    pub fn new(context: Rc<Context>) -> Rc<Self> {
        let res = Rc::new(Self {
            context: context.clone(),
            weak_self: RefCell::new(Default::default()),
        });
        *res.weak_self.borrow_mut() = Rc::downgrade(&res);
        res.initialize();
        res
    }

    fn initialize(&self) {
        let weak_self = self.weak_self.borrow().clone();
        self.context
            .message_manager
            .borrow_mut()
            .register_method_handler(
                "file_open_dialog_channel", //
                move |call, reply, _engine| {
                    if let Some(s) = weak_self.upgrade() {
                        s.on_method_call(call, reply);
                    }
                },
            );
    }

    fn on_method_call(&self, call: MethodCall<Value>, reply: MethodCallReply<Value>) {
        match call.method.as_str() {
            "showFileOpenDialog" => {
                let request: FileOpenRequest = from_value(&call.args).unwrap();
                self.open_file_dialog(request, reply);
            }
            _ => {
                reply.send_error("invalid_method", Some("Invalid method"), Value::Null);
            }
        }
    }

    fn open_file_dialog(&self, request: FileOpenRequest, reply: MethodCallReply<Value>) {
        let win = self
            .context
            .window_manager
            .borrow()
            .get_platform_window(request.parent_window);
        if let Some(win) = win {
            platform::open_file_dialog(win, self.context.clone(), request, |name| {
                let value = match name {
                    Some(name) => Value::String(name),
                    None => Value::Null,
                };
                reply.send(Ok(value));
            });
        } else {
            reply.send_error("no_window", Some("Platform window not found"), Value::Null);
        }
    }
}

impl Drop for FileOpenDialogService {
    fn drop(&mut self) {
        self.context
            .message_manager
            .borrow_mut()
            .unregister_message_handler("file_open_dialog_channel");
    }
}
