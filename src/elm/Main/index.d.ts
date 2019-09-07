// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace Main {
    export interface App {
      ports: {
        orderPlaced: {
          send(data: { orderId: string; customerInfo: { firstName: string; lastName: string; emailAddress: string }; shippingAddress: { line1: string; line2: string; line3: string; line4: string; city: string; zipCode: string }; billingAddress: { line1: string; line2: string; line3: string; line4: string; city: string; zipCode: string }; lines: { orderLineId: string; productCode: string; quantity: number }[] }): void
        }
        orderSucceeded: {
          subscribe(callback: (data: { events: { event: string; timeStamp: number; data: string }[] }) => void): void
        }
        orderFailed: {
          subscribe(callback: (data: { error: { error: string; reason: string } }) => void): void
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: null;
    }): Elm.Main.App;
  }
}