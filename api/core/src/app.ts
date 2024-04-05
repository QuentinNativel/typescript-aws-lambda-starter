import { Hono } from "hono";
import { logger } from "hono/logger";
import helloWorld from "./routes/helloWorld";

const app = new Hono().basePath("/core");

app.use(logger());
app.use(async (c, next) => {
  console.log("here");
  await next();
  console.log(c.res.status);
  console.log(c.res.body);
});
app.route("/hello", helloWorld);

export default app;
