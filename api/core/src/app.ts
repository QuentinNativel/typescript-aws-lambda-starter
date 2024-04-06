import { Hono } from "hono";
import { logger } from "hono/logger";
import helloWorld from "./routes/helloWorld";
import users from "./routes/users";

const app = new Hono().basePath("/core");

app.use(logger());

app.route("/hello", helloWorld);
app.route("/users", users);

export default app;
