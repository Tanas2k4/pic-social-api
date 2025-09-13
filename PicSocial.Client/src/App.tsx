import React, { useState } from "react";
import Login from "./components/Login";
import "./App.css";

const App: React.FC = () => {
  const [isLoggedIn, setIsLoggedIn] = useState<boolean>(
    !!localStorage.getItem("token")
  );

  const handleLogin = () => {
    setIsLoggedIn(true);
  };

  const handleLogout = () => {
    localStorage.removeItem("token");
    setIsLoggedIn(false);
  };

  return (
    <div className="App">
      <h1>PicSocial App</h1>
      {isLoggedIn ? (
        <>
          <h2>Welcome! You are logged in.</h2>
          <button onClick={handleLogout}>Logout</button>
        </>
      ) : (
        <Login onLogin={handleLogin} />
      )}
    </div>
  );
};

export default App;
