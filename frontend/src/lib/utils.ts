import { QueryClient } from "@tanstack/react-query";

export const classNames = (...inputs: (string | undefined)[]) => {
  return inputs.join(" ");
};

export const wait = (duration: number) =>
  new Promise((resolve) => setTimeout(resolve, duration));

export const queryClient = new QueryClient();
