// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace Main {
    export interface App {
      ports: {
        orderReceived: {
          send(data: { orderId: string; customerInfo: string; shippingAddress: string; billingAddress: string; orderLine: string[] }): void
        }
        orderProcessed: {
          subscribe(callback: (data: { acknowledgementSent: boolean; orderPlaced: boolean; billableOrderPlaced: boolean }) => void): void
        }
        orderFailed: {
          subscribe(callback: (data: { field: string; errorDescription: string }[]) => void): void
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: null;
    }): Elm.Main.App;
  }
}