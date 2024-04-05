import { Hono } from "hono";

const helloWorld = new Hono();

helloWorld.get("*", (c) => {
  console.log("here");
  return c.json({ message: "Hello World" });
});

export default helloWorld;
