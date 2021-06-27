use nativeshell::shell::{MethodCallHandler, MethodChannel};
pub use nativeshell::{
    codec::{value::from_value, MethodCall, MethodCallReply, Value},
    shell::{Context, WindowHandle},
};

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

pub struct FileOpenDialog {
    context: Context,
}

impl FileOpenDialog {
    pub fn new(context: Context) -> Self {
        Self { context }
    }

    pub fn register(self) -> MethodChannel {
        MethodChannel::new(self.context.clone(), "file_open_dialog_channel", self)
    }

    fn open_file_dialog(&self, request: FileOpenRequest, reply: MethodCallReply<Value>) {
        if let Some(context) = self.context.get() {
            let win = context
                .window_manager
                .borrow()
                .get_platform_window(request.parent_window);
            if let Some(win) = win {
                platform::open_file_dialog(win, &context, request, |name| {
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
}

impl MethodCallHandler for FileOpenDialog {
    fn on_method_call(
        &mut self,
        call: MethodCall<Value>,
        reply: MethodCallReply<Value>,
        _engine: nativeshell::shell::EngineHandle,
    ) {
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
}
