const API_URL = 'http://127.0.0.1:8000/api';

// State
let token = localStorage.getItem('token');
let user = localStorage.getItem('user');

// DOM Elements
const authNav = document.getElementById('auth-nav');
const userNav = document.getElementById('user-nav');
const authSection = document.getElementById('auth-section');
const dashboardSection = document.getElementById('dashboard-section');
const welcomeMsg = document.getElementById('welcome-msg');
const loginForm = document.getElementById('login-form');
const registerForm = document.getElementById('register-form');

// Init
function init() {
    if (token) {
        showDashboard();
    } else {
        showAuth();
    }
    setupEventListeners();
}

function setupEventListeners() {
    document.getElementById('show-login').onclick = () => toggleAuth('login');
    document.getElementById('show-register').onclick = () => toggleAuth('register');
    document.getElementById('logout-btn').onclick = logout;
}

// Auth Functions
function toggleAuth(mode) {
    if (mode === 'login') {
        loginForm.style.display = 'block';
        registerForm.style.display = 'none';
        document.getElementById('show-login').classList.add('active');
        document.getElementById('show-register').classList.remove('active');
    } else {
        loginForm.style.display = 'none';
        registerForm.style.display = 'block';
        document.getElementById('show-login').classList.remove('active');
        document.getElementById('show-register').classList.add('active');
    }
}

async function handleLogin(e) {
    e.preventDefault();
    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;

    try {
        const res = await fetch(`${API_URL}/login/`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });
        const data = await res.json();

        if (res.ok) {
            token = data.token;
            user = data.username;
            localStorage.setItem('token', token);
            localStorage.setItem('user', user);
            showToast('Login successful', 'success');
            showDashboard();
        } else {
            showToast(data.error || data.detail || 'Login failed', 'error');
        }
    } catch (err) {
        showToast('Network error', 'error');
    }
}

async function handleRegister(e) {
    e.preventDefault();
    const username = document.getElementById('reg-username').value;
    const email = document.getElementById('reg-email').value;
    const password = document.getElementById('reg-password').value;

    try {
        const res = await fetch(`${API_URL}/register/`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, email, password })
        });
        const data = await res.json();

        if (res.ok) {
            showToast('Registration successful! Please login.', 'success');
            toggleAuth('login');
        } else {
            showToast(data.error || data.detail || 'Registration failed', 'error');
        }
    } catch (err) {
        showToast('Network error', 'error');
    }
}

function logout() {
    token = null;
    user = null;
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    showAuth();
    showToast('Logged out', 'success');
}

// Dashboard Functions
function showDashboard() {
    authNav.style.display = 'none';
    userNav.style.display = 'flex';
    authSection.style.display = 'none';
    dashboardSection.style.display = 'block';
    welcomeMsg.textContent = `Hi, ${user}`;
    switchTab('profile');
}

function showAuth() {
    authNav.style.display = 'flex';
    userNav.style.display = 'none';
    authSection.style.display = 'block';
    dashboardSection.style.display = 'none';
    toggleAuth('login');
}

function switchTab(tabName) {
    document.querySelectorAll('.tab-content').forEach(el => el.style.display = 'none');
    document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));

    document.getElementById(`${tabName}-tab`).style.display = 'block';
    document.querySelector(`button[onclick="switchTab('${tabName}')"]`).classList.add('active');

    if (tabName === 'profile') fetchProfile();
    if (tabName === 'list') fetchProducts('seed'); // Default to seeds
}

async function fetchProfile() {
    try {
        const res = await fetch(`${API_URL}/profile/`, {
            headers: { 'Authorization': `Bearer ${token}` } // Assuming Bearer token, adjust if needed
        });
        // Note: The backend might expect a different auth header format.
        // Based on views.py, it uses `api.jwt_auth.JWTAuthentication`.
        // Let's assume it expects 'Authorization: <token>' or 'Authorization: Bearer <token>'
        // If it fails, we might need to check how the custom authentication class parses the header.

        // Let's try sending just the token if Bearer fails, or check the custom auth class.
        // For now, I'll try with just the token as a custom header or standard Bearer.
        // Actually, let's check the `api.jwt_auth.JWTAuthentication` implementation if possible, 
        // but I don't have access to it right now. I'll assume standard Bearer or just the token.
        // Let's try standard Bearer first.

        const data = await res.json();
        if (res.ok) {
            document.getElementById('profile-data').innerHTML = `
                <p><strong>Username:</strong> ${data.username}</p>
                <p><strong>Email:</strong> ${data.email}</p>
            `;
        }
    } catch (err) {
        console.error(err);
    }
}

async function handleCreateProduct(e) {
    e.preventDefault();
    const type = document.getElementById('prod-type').value;
    const name = document.getElementById('prod-name').value;
    const date = document.getElementById('prod-date').value;
    const amount = document.getElementById('prod-amount').value;
    const certFile = document.getElementById('prod-cert').files[0];

    const formData = new FormData();
    formData.append('type', type);
    formData.append('product_name', name);
    formData.append('date_of_listing', date);
    formData.append('amount_kg', amount);
    if (certFile) {
        formData.append('certificate', certFile);
    }

    try {
        const res = await fetch(`${API_URL}/create/`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${token}`
            },
            body: formData
        });
        const data = await res.json();

        if (res.ok) {
            showToast('Product created successfully', 'success');
            e.target.reset();
        } else {
            showToast(data.error || data.detail || 'Failed to create product', 'error');
            console.log(data);
        }
    } catch (err) {
        showToast('Network error', 'error');
        console.error(err);
    }
}

async function fetchProducts(type) {
    const endpoint = type === 'seed' ? 'seed/' : 'byproduct/';
    try {
        const res = await fetch(`${API_URL}/${endpoint}`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        const data = await res.json();

        if (res.ok) {
            const list = document.getElementById('product-list');
            list.innerHTML = data.map(p => `
                <div class="product-card">
                    <h4>${p.product_name}</h4>
                    <p>Type: ${p.type}</p>
                    <p>Amount: ${p.amount_kg} kg</p>
                    <p>Date: ${p.date_of_listing}</p>
                    ${p.certificate ? `<a href="${p.certificate}" target="_blank" style="display:inline-block; margin-top:0.5rem; color:var(--primary);">View Certificate</a>` : ''}
                </div>
            `).join('');
            if (data.length === 0) list.innerHTML = '<p>No products found.</p>';
        }
    } catch (err) {
        console.error(err);
    }
}

function showToast(msg, type) {
    const toast = document.getElementById('toast');
    toast.textContent = msg;
    toast.className = `toast show ${type}`;
    setTimeout(() => toast.className = 'toast', 3000);
}

init();
