use std::{rc::Rc, thread, time::Duration};

use nativeshell::{
    codec::{MethodCall, MethodCallReply, Value},
    shell::{Context, EngineHandle, MethodCallHandler, Plugin, RunLoopSender},
    util::Capsule,
};

pub struct PlatformChannels {
    // sender is used to schedule responde on main thread
    sender: RunLoopSender,
}

impl PlatformChannels {
    pub fn create_plugin(context: Rc<Context>) -> Plugin {
        Plugin::new(
            context.clone(),
            "example_channel",
            PlatformChannels {
                sender: context.run_loop.borrow_mut().new_sender(),
            },
        )
    }
}

impl MethodCallHandler for PlatformChannels {
    fn on_method_call(
        &mut self,
        call: MethodCall<Value>,
        reply: MethodCallReply<Value>,
        _engine: EngineHandle,
    ) {
        match call.method.as_str() {
            "echo" => {
                reply.send_ok(call.args);
            }
            "backgroundTask" => {
                // reply is not thread safe and can not be sent between threads directly;
                // use capsule to move it between threads
                let mut reply = Capsule::new(reply);

                let sender = self.sender.clone();
                thread::spawn(move || {
                    // simulate long running task on background thread
                    thread::sleep(Duration::from_secs(1));
                    let value = 3.141592;
                    // jump back to platform thread to send the reply
                    sender.send(move || {
                        // capsule will only let us take the stored value on thread where
                        // it was created
                        let reply = reply.take().unwrap();
                        reply.send_ok(Value::F64(value));
                    });
                });
            }
            _ => {}
        }
    }
}
