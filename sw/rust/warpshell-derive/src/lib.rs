extern crate proc_macro;

use proc_macro::TokenStream;
use quote::quote;
use syn::{self, DeriveInput};

#[proc_macro_derive(GetCtrlChannel)]
pub fn derive_get_ctrl_channel(input: TokenStream) -> TokenStream {
    let ast = syn::parse(input).unwrap();
    impl_get_ctrl_channel(&ast)
}

#[proc_macro_derive(GetDmaChannel)]
pub fn derive_get_dma_channel(input: TokenStream) -> TokenStream {
    let ast = syn::parse(input).unwrap();
    impl_get_dma_channel(&ast)
}

fn impl_get_ctrl_channel(ast: &DeriveInput) -> TokenStream {
    let ty = &ast.ident;
    let generics = &ast.generics;
    let tokens = quote! {
        impl #generics GetCtrlChannel for #ty #generics {
            fn get_ctrl_channel(&self) -> &CtrlChannel {
                self.ctrl_channel
            }
        }
    };
    tokens.into()
}

fn impl_get_dma_channel(ast: &DeriveInput) -> TokenStream {
    let ty = &ast.ident;
    let generics = &ast.generics;
    let tokens = quote! {
        impl #generics GetDmaChannel for #ty #generics {
            fn get_dma_channel(&self) -> &DmaChannel {
                self.dma_channel
            }
        }
    };
    tokens.into()
}
