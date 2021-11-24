use std::{mem::size_of, ptr::null_mut};

use nativeshell::shell::ContextRef;
pub use widestring::WideStr;
use windows::Win32::{
    Foundation::{HINSTANCE, HWND, LPARAM, PWSTR},
    UI::Controls::Dialogs::{
        GetOpenFileNameW, OPENFILENAMEW, OPEN_FILENAME_FLAGS, OPEN_FILENAME_FLAGS_EX,
    },
};

use super::FileOpenRequest;

pub(super) fn open_file_dialog<F>(
    win: isize,
    context: &ContextRef,
    _request: FileOpenRequest,
    reply: F,
) where
    F: FnOnce(Option<String>) + 'static,
{
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

        let res = unsafe { GetOpenFileNameW(&mut ofn as *mut _).as_bool() };
        if !res {
            reply(None);
        } else {
            let name = WideStr::from_slice(&file).to_string_lossy();
            reply(Some(name));
        }
    };

    context.run_loop.borrow().schedule_now(cb).detach();
}
