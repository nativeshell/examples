use std::cell::RefCell;

pub use block::ConcreteBlock;
pub use cocoa::{
    base::id,
    foundation::{NSArray, NSString, NSUInteger},
};
use nativeshell::shell::ContextRef;
pub use objc::{
    msg_send,
    rc::{autoreleasepool, StrongPtr},
};

use super::FileOpenRequest;

fn from_nsstring(ns_string: id) -> String {
    use std::os::raw::c_char;
    use std::slice;
    unsafe {
        let bytes: *const c_char = msg_send![ns_string, UTF8String];
        let bytes = bytes as *const u8;
        let len = NSString::len(ns_string);
        let bytes = slice::from_raw_parts(bytes, len);
        std::str::from_utf8(bytes).unwrap().into()
    }
}

pub(super) fn open_file_dialog<F>(
    win: StrongPtr,
    _context: &ContextRef,
    _request: FileOpenRequest,
    reply: F,
) where
    F: FnOnce(Option<String>) + 'static,
{
    autoreleasepool(|| unsafe {
        let panel = StrongPtr::retain(msg_send![class!(NSOpenPanel), openPanel]);

        // We know that the callback will be called only once, but rust doesn't;
        let reply = RefCell::new(Some(reply));

        let panel_copy = panel.clone();
        let cb = move |response: NSUInteger| {
            let reply = reply.take();
            if let Some(reply) = reply {
                if response == 1 {
                    let urls: id = msg_send![*panel_copy, URLs];
                    if NSArray::count(urls) > 0 {
                        let url = NSArray::objectAtIndex(urls, 0);
                        let string: id = msg_send![url, absoluteString];
                        let path = from_nsstring(string);
                        reply(Some(path));
                        return;
                    }
                }
                reply(None);
            }
        };

        let handler = ConcreteBlock::new(cb).copy();
        let () = msg_send![*panel, beginSheetModalForWindow: win completionHandler:&*handler];
    });
}
