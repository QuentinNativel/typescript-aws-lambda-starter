import postgres from "postgres";

import { SSMClient, GetParameterCommand } from "@aws-sdk/client-ssm";

const ssmClient = new SSMClient();

let supabaseUrl: string | undefined = undefined;

const getSupabaseUrl = async (): Promise<string> => {
  if (supabaseUrl !== undefined) {
    return supabaseUrl;
  }

  try {
    const command = new GetParameterCommand({
      Name: process.env.SUPABASE_URL_NAME,
      WithDecryption: true,
    });

    const response = await ssmClient.send(command);
    const supabaseUrl = response.Parameter?.Value;

    if (!supabaseUrl) {
      throw new Error(
        `Failed to retrieve the value for supabase URL from the SSM parameter store`
      );
    }

    return supabaseUrl;
  } catch (error) {
    console.error("Error retrieving the Supabase URL:", error);
    throw error;
  }
};

type User = {
  id: number;
  fullName: string;
  phone: string;
};

export const getUsers = async (): Promise<User[]> => {
  const url = await getSupabaseUrl();
  console.log({ url });
  // Use the retrieved Supabase URL here
  const sql = postgres(url, { prepare: false });
  const users = await sql`SELECT * FROM users`;
  console.log({ users, sql });

  return users as unknown as User[];
};
