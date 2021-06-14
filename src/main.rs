use file_open_dialog::FileOpenDialog;
use nativeshell::{
    codec::Value,
    shell::{exec_bundle, register_observatory_listener, Context, ContextOptions},
};
use platform_channels::PlatformChannels;

#[cfg(target_os = "macos")]
#[macro_use]
extern crate objc;

mod file_open_dialog;
mod platform_channels;

nativeshell::include_flutter_plugins!();

fn main() {
    exec_bundle();
    register_observatory_listener("nativeshell_examples".into());

    env_logger::builder().format_timestamp(None).init();

    let context = Context::new(ContextOptions {
        app_namespace: "NativeShellDemo".into(),
        flutter_plugins: flutter_get_plugins(),
        ..Default::default()
    });

    let context = context.unwrap();

    let _file_open_dialog = FileOpenDialog::create_channel(context.clone());
    let _platform_channels = PlatformChannels::create_channel(context.clone());

    context
        .window_manager
        .borrow_mut()
        .create_window(Value::Null, None);

    context.run_loop.borrow().run();
}
