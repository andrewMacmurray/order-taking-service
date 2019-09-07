interface Handlers<I, O> {
  onSuccess: { subscribe(out: (O) => void): void };
  onError: { subscribe(out: (O) => void): void };
  start: { send(input: I): void };
}

export function process<I, O>(input: I, handlers: Handlers<I, O>): Promise<O> {
  return new Promise(resolve => {
    handlers.onSuccess.subscribe(resolve);
    handlers.onError.subscribe(resolve);
    handlers.start.send(input);
  });
}
