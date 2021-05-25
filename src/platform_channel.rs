use std::{rc::Rc, thread, time::Duration};

use nativeshell::{codec::Value, shell::Context, util::Capsule};

// Register the 'echo' and 'background' platform handlers
pub(super) fn register_example_channel(context: Rc<Context>) {
    let context_clone = context.clone();
    context
        .message_manager
        .borrow_mut()
        .register_method_handler("example_channel", move |call, reply, _engine| {
            match call.method.as_str() {
                "echo" => {
                    reply.send_ok(call.args);
                }
                "backgroundTask" => {
                    // reply is not thread safe and can not be sent between threads directly;
                    // use capsule to move it between threads
                    let mut reply = Capsule::new(reply);

                    let sender = context_clone.run_loop.borrow().new_sender();
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
        });
}
