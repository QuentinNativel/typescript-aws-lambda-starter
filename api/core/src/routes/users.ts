import { Hono } from "hono";
import { getUsers } from "../adapters/supabaseAdapter";

const users = new Hono();

users.get("/", async (c) => {
  console.log("there");
  const users = await getUsers();
  return c.json({
    data: users,
    foo: "bar",
  });
});

export default users;
