mod bindings {
    ::windows::include_bindings!();
}

use std::{mem::size_of, ptr::null_mut, rc::Rc};

pub use bindings::Windows::Win32::{System::SystemServices::*, UI::WindowsAndMessaging::*};
use nativeshell::{
    codec::{MethodCallReply, Value},
    shell::Context,
};
pub use widestring::WideStr;

use super::FileOpenRequest;

pub(super) fn open_file_dialog(
    win: isize,
    context: Rc<Context>,
    _request: FileOpenRequest,
    reply: MethodCallReply<Value>,
) {
    let cb = move || {
        let mut file = Vec::<u16>::new();
        file.resize(4096, 0);

        let mut ofn = OPENFILENAMEW {
            lStructSize: size_of::<OPENFILENAMEW>() as u32,
            hwndOwner: HWND(win),
            hInstance: HINSTANCE(0),
            lpstrFilter: PWSTR::default(),
            lpstrCustomFilter: PWSTR::default(),
            nMaxCustFilter: 0,
            nFilterIndex: 0,
            lpstrFile: PWSTR(file.as_mut_ptr()),
            nMaxFile: file.len() as u32,
            lpstrFileTitle: PWSTR::default(),
            nMaxFileTitle: 0,
            lpstrInitialDir: PWSTR::default(),
            lpstrTitle: PWSTR::default(),
            Flags: OPEN_FILENAME_FLAGS(0),
            nFileOffset: 0,
            nFileExtension: 0,
            lpstrDefExt: PWSTR::default(),
            lCustData: LPARAM(0),
            lpfnHook: None,
            lpTemplateName: PWSTR::default(),
            pvReserved: null_mut(),
            dwReserved: 0,
            FlagsEx: OPEN_FILENAME_FLAGS_EX(0),
        };

        let res = unsafe { GetOpenFileNameW(&mut ofn as *mut _) == TRUE };
        if !res {
            reply.send_ok(Value::Null);
        } else {
            let name = WideStr::from_slice(&file).to_string_lossy();
            reply.send_ok(Value::String(name));
        }
    };
    context.run_loop.borrow().schedule_now(cb).detach();
}
