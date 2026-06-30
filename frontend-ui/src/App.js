// export default App;

import React, { useState, useEffect, useCallback } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [users, setUsers] = useState([]);
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

//   const USER_API = process.env.REACT_APP_USER_API || 'http://user-service:3001';
//   const PRODUCT_API = process.env.REACT_APP_PRODUCT_API || 'http://product-service:3002';

const USER_API = process.env.REACT_APP_USER_API || 'http://user-service:3001';
const PRODUCT_API = process.env.REACT_APP_PRODUCT_API || 'http://product-service:3002';


  // Wrap fetchData in useCallback so it's stable across renders
  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      const usersRes = await axios.get(`${USER_API}/api/users`);
      const productsRes = await axios.get(`${PRODUCT_API}/api/products`);

      setUsers(usersRes.data);
      setProducts(productsRes.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch data from microservices');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, [USER_API, PRODUCT_API]); // dependencies are stable values

  //  Call fetchData once on mount
  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return (
    <div className="App">
      <header className="App-header">
        <h1> DevSecOps Dashboard</h1>
        <p>Secure Microservices Architecture</p>
      </header>

      <main className="container">
        {error && <div className="error-banner">{error}</div>}

        <section className="dashboard">
          <div className="card users-card">
            <h2>Users Service</h2>
            {loading ? (
              <p>Loading users...</p>
            ) : (
              <>
                <p className="count">{users.length} Users</p>
                <ul className="user-list">
                  {users.map((user) => (
                    <li key={user.id}>{user.name} ({user.email})</li>
                  ))}
                </ul>
              </>
            )}
          </div>

          <div className="card products-card">
            <h2> Products Service</h2>
            {loading ? (
              <p>Loading products...</p>
            ) : (
              <>
                <p className="count">{products.length} Products</p>
                <ul className="product-list">
                  {products.map((product) => (
                    <li key={product.id}>
                      {product.name} - ${product.price}
                    </li>
                  ))}
                </ul>
              </>
            )}
          </div>
        </section>

        <section className="services-status">
          <h2> Service Status</h2>
          <div className="status-grid">
            <div className="status-item">
              <span className="status-badge online">●</span>
              <p>User Service (3001)</p>
            </div>
            <div className="status-item">
              <span className="status-badge online">●</span>
              <p>Product Service (3002)</p>
            </div>
            <div className="status-item">
              <span className="status-badge online">●</span>
              <p>Istio Service Mesh</p>
            </div>
            <div className="status-item">
              <span className="status-badge online">●</span>
              <p>ArgoCD Deployed</p>
            </div>
          </div>
        </section>

        <button className="refresh-btn" onClick={fetchData}>
           Refresh Data
        </button>
      </main>

      <footer>
        <p>Deployed with Jenkins CI/CD & ArgoCD | Secured with Istio Service Mesh</p>
      </footer>
    </div>
  );
}

export default App;
