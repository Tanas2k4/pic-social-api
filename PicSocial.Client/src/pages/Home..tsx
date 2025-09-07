import { useEffect, useState } from "react";
import { api } from "../api/client";

export default function Home() {
  const [msg, setMsg] = useState("");

  useEffect(() => {
    api.get("/ping").then((res) => setMsg(res.data.message));
  }, []);
  return <h1 className="text-2xl font-bold">API say: {msg}</h1>;
}
