import { Elm } from "../elm/Main";

export interface Context {
  worker(): Elm.Main.App["ports"];
}

export const context: Context = {
  worker: () => Elm.Main.init({ flags: null }).ports
};
