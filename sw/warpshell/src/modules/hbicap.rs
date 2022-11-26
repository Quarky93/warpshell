use super::io::{Readable, Writable, ReadWritableAddressSpace, ReadableAddressSpace, WritableAddressSpace};

pub struct HbIcap<'a> {
    pub ctrl: ReadWritableAddressSpace<'a>,
    pub read: ReadableAddressSpace<'a>,
    pub write: WritableAddressSpace<'a>
}

// -- REGISTER MAP ----------------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------------------------------
