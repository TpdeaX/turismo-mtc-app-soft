<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>



<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Dashboard Admin</title>

<!-- Fonts & Icons -->
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,0,0" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>

<style>
/* --- Dashboard Specific Styles (Material Design 3 Premium) --- */
:root {
  /* MD3 Color Tokens - Pink Theme */
  --md-primary: #EC407A;
  --md-primary-container: rgba(236, 64, 122, 0.12);
  --md-on-primary: #FFFFFF;
  --md-on-primary-container: #880E4F;
  --primary-pink: #EC407A;
  --primary-soft: rgba(236, 64, 122, 0.12);
  --primary-rose: #F8BBD9;
  --primary-pastel: #FCE4EC;
  --accent-purple: #BA68C8;
  --accent-purple-soft: rgba(186, 104, 200, 0.12);
  --accent-orange: #FFB74D;
  --accent-orange-soft: rgba(255, 183, 77, 0.12);
  --accent-blue: #64B5F6;
  --accent-blue-soft: rgba(100, 181, 246, 0.12);
  --accent-green: #81C784;
  --accent-green-soft: rgba(129, 199, 132, 0.12);
  --text-dark: #37474F;
  --text-muted: #78909C;
  --bg-soft: #FAFBFC;
  --surface-1: #FFFFFF;
  --surface-2: #F8F9FA;
  --surface-3: #F1F3F4;
  --card-shadow: 0 1px 3px rgba(0, 0, 0, 0.08), 0 4px 12px rgba(0, 0, 0, 0.05);
  --card-hover-shadow: 0 8px 30px rgba(236, 64, 122, 0.15), 0 4px 12px rgba(0, 0, 0, 0.08);
  --radius-xl: 28px;
  --radius-lg: 20px;
  --radius-md: 16px;
  --radius-sm: 12px;
  
  /* Animation tokens */
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
  --ease-smooth: cubic-bezier(0.25, 0.8, 0.25, 1);
  --ease-bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55);
  --duration-fast: 0.2s;
  --duration-normal: 0.3s;
  --duration-slow: 0.5s;
}

body {
  font-family: 'Outfit', sans-serif;
  background-color: var(--bg-soft);
}

.dashboard-container {
  padding: 32px 40px;
  max-width: 1600px;
  width: 100%;
  margin: 0 auto;
  box-sizing: border-box;
  animation: pageEnter 0.8s var(--ease-smooth);
}

/* === ENTRY ANIMATIONS === */
@keyframes pageEnter {
  from { 
    opacity: 0; 
    transform: translateY(20px) scale(0.98);
  }
  to { 
    opacity: 1; 
    transform: translateY(0) scale(1);
  }
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideInRight {
  from { opacity: 0; transform: translateX(30px); }
  to { opacity: 1; transform: translateX(0); }
}

@keyframes slideInLeft {
  from { opacity: 0; transform: translateX(-30px); }
  to { opacity: 1; transform: translateX(0); }
}

@keyframes scaleIn {
  from { opacity: 0; transform: scale(0.9); }
  to { opacity: 1; transform: scale(1); }
}

@keyframes bounceIn {
  0% { opacity: 0; transform: scale(0.3); }
  50% { transform: scale(1.05); }
  70% { transform: scale(0.95); }
  100% { opacity: 1; transform: scale(1); }
}

@keyframes popIn {
  0% { opacity: 0; transform: scale(0.8) rotate(-5deg); }
  60% { transform: scale(1.1) rotate(2deg); }
  100% { opacity: 1; transform: scale(1) rotate(0); }
}

@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

@keyframes iconWiggle {
  0%, 100% { transform: rotate(0deg); }
  25% { transform: rotate(-5deg); }
  75% { transform: rotate(5deg); }
}

@keyframes iconBounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-4px); }
}

@keyframes ripple {
  0% { box-shadow: 0 0 0 0 rgba(236, 64, 122, 0.4); }
  100% { box-shadow: 0 0 0 20px rgba(236, 64, 122, 0); }
}

@keyframes glow {
  0%, 100% { box-shadow: 0 0 5px rgba(236, 64, 122, 0.3); }
  50% { box-shadow: 0 0 20px rgba(236, 64, 122, 0.6); }
}

@keyframes countUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* --- Welcome Section --- */
.welcome-banner {
  background: linear-gradient(135deg, #FFF0F5 0%, #FCE4EC 100%);
  border-radius: var(--radius-xl);
  padding: 40px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: relative;
  overflow: hidden;
  margin-bottom: 24px;
  border: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: var(--card-shadow);
  animation: slideInLeft 0.6s var(--ease-smooth);
}

.welcome-banner::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -10%;
  width: 300px;
  height: 300px;
  background: radial-gradient(circle, rgba(233, 30, 99, 0.1) 0%, transparent 70%);
  border-radius: 50%;
  animation: floatDecor 6s ease-in-out infinite;
}

.welcome-banner::after {
  content: '';
  position: absolute;
  bottom: -30%;
  left: 10%;
  width: 200px;
  height: 200px;
  background: radial-gradient(circle, rgba(186, 104, 200, 0.08) 0%, transparent 70%);
  border-radius: 50%;
  animation: floatDecor 8s ease-in-out infinite reverse;
}

@keyframes floatDecor {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(5deg); }
}

.welcome-text {
  animation: fadeIn 0.8s var(--ease-smooth) 0.2s backwards;
}

.welcome-text h1 {
  font-size: 2.2rem;
  font-weight: 700;
  color: #880E4F;
  margin: 0 0 8px 0;
  letter-spacing: -0.5px;
}

.welcome-text p {
  color: #AD1457;
  font-size: 1.1rem;
  margin: 0;
  font-weight: 400;
}

.highlight-user {
  position: relative;
  display: inline-block;
  animation: popIn 0.6s var(--ease-spring) 0.4s backwards;
}

.highlight-user::after {
  content: '';
  position: absolute;
  bottom: 2px;
  left: 0;
  width: 100%;
  height: 8px;
  background: rgba(233, 30, 99, 0.15);
  z-index: -1;
  border-radius: 4px;
  animation: shimmerBg 3s ease-in-out infinite;
}

@keyframes shimmerBg {
  0%, 100% { background: rgba(233, 30, 99, 0.15); }
  50% { background: rgba(233, 30, 99, 0.25); }
}

.date-badge {
  background: #fff;
  padding: 12px 24px;
  border-radius: 50px;
  display: flex;
  align-items: center;
  gap: 10px;
  color: var(--accent-purple);
  font-weight: 600;
  font-size: 0.95rem;
  box-shadow: 0 4px 16px rgba(0,0,0,0.06);
  animation: slideInRight 0.6s var(--ease-smooth) 0.3s backwards;
  transition: transform var(--duration-fast) var(--ease-smooth), box-shadow var(--duration-fast);
  z-index: 1;
}

/* .date-badge:hover removed */

.date-badge .material-symbols-rounded {
  animation: iconBounce 2s ease-in-out infinite;
}

/* --- Date Filter Bar --- */
.filter-bar {
  background: #fff;
  border-radius: var(--radius-md);
  padding: 16px 24px;
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 24px;
  box-shadow: var(--card-shadow);
  flex-wrap: wrap;
  animation: fadeIn 0.6s var(--ease-smooth) 0.2s backwards;
}

.filter-bar label {
  font-weight: 600;
  color: var(--text-dark);
  display: flex;
  align-items: center;
  gap: 8px;
}

.filter-bar label .material-symbols-rounded {
  transition: transform var(--duration-normal) var(--ease-spring);
}

.filter-bar:hover label .material-symbols-rounded {
  animation: iconWiggle 0.5s var(--ease-spring);
}

.filter-btn {
  padding: 10px 20px;
  border: 2px solid #e0e0e0;
  background: #fff;
  border-radius: 50px;
  font-weight: 600;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all var(--duration-normal) var(--ease-smooth);
  color: var(--text-muted);
  position: relative;
  overflow: hidden;
}

.filter-btn::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  background: rgba(236, 64, 122, 0.1);
  border-radius: 50%;
  transform: translate(-50%, -50%);
  transition: width 0.4s, height 0.4s;
}

.filter-btn:hover::before {
  width: 200%;
  height: 200%;
}

.filter-btn:hover {
  border-color: var(--primary-pink);
  color: var(--primary-pink);
  transform: translateY(-2px);
}

.filter-btn.active {
  background: var(--primary-pink);
  border-color: var(--primary-pink);
  color: #fff;
  transform: scale(1.02);
  box-shadow: 0 4px 12px rgba(236, 64, 122, 0.3);
}

.filter-btn.active::before {
  display: none;
}

.date-inputs {
  display: none;
  align-items: center;
  gap: 8px;
  margin-left: auto;
  animation: slideInRight 0.3s var(--ease-smooth);
}

.date-inputs.show {
  display: flex;
}

.date-inputs input {
  padding: 10px 14px;
  border: 2px solid #e0e0e0;
  border-radius: var(--radius-sm);
  font-family: 'Outfit', sans-serif;
  font-size: 0.9rem;
  transition: border-color var(--duration-fast), box-shadow var(--duration-fast);
}

.date-inputs input:focus {
  outline: none;
  border-color: var(--primary-pink);
  box-shadow: 0 0 0 4px rgba(236, 64, 122, 0.1);
}

.apply-btn {
  padding: 10px 20px;
  background: linear-gradient(135deg, var(--primary-pink) 0%, #D81B60 100%);
  border: none;
  border-radius: var(--radius-sm);
  color: white;
  font-weight: 600;
  cursor: pointer;
  transition: transform var(--duration-fast), box-shadow var(--duration-fast);
}

.apply-btn:hover {
  transform: scale(1.05) translateY(-2px);
  box-shadow: 0 6px 20px rgba(236, 64, 122, 0.4);
}

.apply-btn:active {
  transform: scale(0.98);
}

/* --- KPI Grid --- */
.kpi-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

/* Staggered entry animations for KPI cards */
.kpi-card {
  background: #fff;
  padding: 24px;
  border-radius: var(--radius-md);
  border: 1px solid rgba(0,0,0,0.02);
  box-shadow: var(--card-shadow);
  transition: transform var(--duration-normal) var(--ease-spring), 
              box-shadow var(--duration-normal) var(--ease-smooth);
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  /* cursor: pointer; removed from base class */
  animation: scaleIn 0.5s var(--ease-spring) backwards;
}

.kpi-card[onclick] {
  cursor: pointer;
}

.kpi-card:nth-child(1) { animation-delay: 0.1s; }
.kpi-card:nth-child(2) { animation-delay: 0.2s; }
.kpi-card:nth-child(3) { animation-delay: 0.3s; }
.kpi-card:nth-child(4) { animation-delay: 0.4s; }
.kpi-card:nth-child(5) { animation-delay: 0.5s; }

.kpi-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
  transition: left 0.5s;
}

.kpi-card:hover::before {
  left: 100%;
}

.kpi-card[onclick]:hover {
  transform: translateY(-8px) scale(1.02);
  box-shadow: var(--card-hover-shadow);
}

.kpi-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.kpi-icon-wrapper {
  width: 52px;
  height: 52px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 26px;
  transition: transform var(--duration-normal) var(--ease-spring),
              box-shadow var(--duration-normal);
}

.kpi-card[onclick]:hover .kpi-icon-wrapper {
  transform: scale(1.15) rotate(8deg);
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.kpi-icon-wrapper .material-symbols-rounded {
  transition: transform var(--duration-normal) var(--ease-spring);
}

.kpi-card[onclick]:hover .kpi-icon-wrapper .material-symbols-rounded {
  animation: iconWiggle 0.6s var(--ease-spring);
}

.kpi-value {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--text-dark);
  line-height: 1;
  margin-bottom: 4px;
  animation: countUp 0.5s var(--ease-smooth) backwards;
}

.kpi-label {
  font-size: 0.9rem;
  color: var(--text-muted);
  font-weight: 500;
}

.kpi-action {
  margin-top: auto;
  padding-top: 12px;
  border-top: 1px solid #f0f0f0;
  font-size: 0.85rem;
  color: var(--primary-pink);
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: gap var(--duration-fast) var(--ease-smooth);
}

.kpi-action .material-symbols-rounded {
  transition: transform var(--duration-fast) var(--ease-spring);
}

.kpi-card[onclick]:hover .kpi-action {
  gap: 8px;
}

.kpi-card[onclick]:hover .kpi-action .material-symbols-rounded {
  transform: translateX(4px);
}

/* Specific KPI Colors - Soft Pastels */
.kpi-pink .kpi-icon-wrapper { background: var(--primary-soft); color: var(--primary-pink); }
.kpi-orange .kpi-icon-wrapper { background: var(--accent-orange-soft); color: #EF6C00; }
.kpi-purple .kpi-icon-wrapper { background: var(--accent-purple-soft); color: var(--accent-purple); }
.kpi-green .kpi-icon-wrapper { background: var(--accent-green-soft); color: var(--accent-green); }
.kpi-blue .kpi-icon-wrapper { background: var(--accent-blue-soft); color: var(--accent-blue); }

/* --- Empty State --- */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 24px;
  text-align: center;
  color: var(--text-muted);
  animation: fadeIn 0.5s ease;
}

.empty-state .material-symbols-rounded {
  font-size: 56px;
  color: #CFD8DC;
  margin-bottom: 16px;
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
}

.empty-state h4 {
  margin: 0 0 8px;
  color: var(--text-dark);
  font-weight: 600;
  font-size: 1.1rem;
}

.empty-state p {
  margin: 0;
  font-size: 0.9rem;
  max-width: 200px;
}

/* Empty Chart Placeholder */
.empty-chart-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  min-height: 200px;
  background: linear-gradient(180deg, #FAFBFC 0%, #F5F7F9 100%);
  border-radius: 12px;
  border: 2px dashed #E0E7EC;
}

.empty-chart-placeholder .material-symbols-rounded {
  font-size: 48px;
  color: #B0BEC5;
  margin-bottom: 12px;
}

.empty-chart-placeholder p {
  margin: 0;
  color: var(--text-muted);
  font-size: 0.9rem;
  font-weight: 500;
}


.charts-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 24px;
  margin-bottom: 24px;
}

.charts-row {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
  margin-bottom: 24px;
}

.chart-card {
  background: #fff;
  padding: 28px;
  border-radius: var(--radius-lg);
  box-shadow: var(--card-shadow);
  border: 1px solid rgba(0,0,0,0.02);
  transition: transform var(--duration-normal) var(--ease-smooth), 
              box-shadow var(--duration-normal);
  animation: fadeInUp 0.6s var(--ease-smooth) backwards;
}

.charts-grid .chart-card:nth-child(1) { animation-delay: 0.3s; }
.charts-grid .chart-card:nth-child(2) { animation-delay: 0.4s; }
.charts-row .chart-card:nth-child(1) { animation-delay: 0.5s; }
.charts-row .chart-card:nth-child(2) { animation-delay: 0.6s; }
.charts-row .chart-card:nth-child(3) { animation-delay: 0.7s; }

/* .chart-card:hover removed */

@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.section-title h3 {
  font-size: 1.15rem;
  font-weight: 600;
  color: var(--text-dark);
  margin: 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.section-title h3 .material-symbols-rounded {
  font-size: 20px;
  color: var(--primary-pink);
  transition: transform var(--duration-normal) var(--ease-spring);
}

/* .chart-card:hover .section-title h3 .material-symbols-rounded removed */

.chart-wrapper {
  position: relative;
  height: 300px;
  width: 100%;
}


.best-employee-card {
  background: linear-gradient(135deg, #EC407A 0%, #AB47BC 100%);
  color: white;
  padding: 32px;
  border-radius: var(--radius-xl);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  min-height: 220px;
  position: relative;
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(236, 64, 122, 0.25);
  animation: scaleIn 0.6s var(--ease-spring) 0.4s backwards;
  transition: transform var(--duration-normal) var(--ease-smooth),
              box-shadow var(--duration-normal);
}

/* .best-employee-card:hover removed */

.best-employee-card::before {
  content: '';
  position: absolute;
  top: -30%;
  right: -20%;
  width: 150px;
  height: 150px;
  background: rgba(255,255,255,0.1);
  border-radius: 50%;
  animation: floatDecor 6s ease-in-out infinite;
}

.best-employee-card::after {
  content: '';
  position: absolute;
  bottom: -20%;
  left: -10%;
  width: 100px;
  height: 100px;
  background: rgba(255,255,255,0.08);
  border-radius: 50%;
  animation: floatDecor 8s ease-in-out infinite reverse;
}

.best-employee-card .medal-icon {
  font-size: 56px;
  margin-bottom: 16px;
  filter: drop-shadow(0 4px 12px rgba(0,0,0,0.25));
  animation: medalPulse 2.5s ease-in-out infinite;
  z-index: 1;
}

@keyframes medalPulse {
  0%, 100% { 
    transform: scale(1) rotate(0deg); 
    filter: drop-shadow(0 4px 12px rgba(0,0,0,0.25));
  }
  50% { 
    transform: scale(1.1) rotate(5deg); 
    filter: drop-shadow(0 8px 20px rgba(0,0,0,0.35));
  }
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.08); }
}

.best-employee-card h4 {
  margin: 0 0 8px;
  font-size: 0.95rem;
  opacity: 0.9;
  font-weight: 400;
  letter-spacing: 0.3px;
  z-index: 1;
}

.best-employee-card .name {
  font-size: 1.4rem;
  font-weight: 700;
  margin-bottom: 8px;
  letter-spacing: -0.3px;
  z-index: 1;
  animation: fadeIn 0.5s var(--ease-smooth) 0.6s backwards;
}

.best-employee-card .stats {
  font-size: 0.9rem;
  opacity: 0.85;
  display: flex;
  align-items: center;
  gap: 6px;
  z-index: 1;
}

.best-employee-card .stats .material-symbols-rounded {
  font-size: 18px;
  animation: iconBounce 2s ease-in-out infinite;
}

/* Empty Best Employee - Dark mode compatible with proper styling */
.best-employee-card.empty {
  background: linear-gradient(135deg, #455A64 0%, #37474F 100%);
  box-shadow: 0 8px 32px rgba(0,0,0,0.2);
}

.best-employee-card.empty .medal-icon {
  animation: float 3s ease-in-out infinite;
  opacity: 0.7;
}

.best-employee-card.empty h4 {
  color: rgba(255,255,255,0.9);
}

.best-employee-card.empty .name {
  color: rgba(255,255,255,0.95);
}

.best-employee-card.empty .stats {
  opacity: 0.7;
}

/* --- Quick Actions --- */
.quick-actions-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--text-dark);
  margin-bottom: 20px;
  animation: fadeIn 0.5s var(--ease-smooth) 0.8s backwards;
}

.actions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.action-card {
  background: #fff;
  padding: 24px 20px;
  border-radius: var(--radius-md);
  box-shadow: var(--card-shadow);
  cursor: pointer;
  transition: all var(--duration-normal) var(--ease-spring);
  border: 2px solid transparent;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 12px;
  animation: bounceIn 0.5s var(--ease-spring) backwards;
  position: relative;
  overflow: hidden;
}

.action-card:nth-child(1) { animation-delay: 0.9s; }
.action-card:nth-child(2) { animation-delay: 1.0s; }
.action-card:nth-child(3) { animation-delay: 1.1s; }
.action-card:nth-child(4) { animation-delay: 1.2s; }

.action-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(236, 64, 122, 0.05) 0%, rgba(186, 104, 200, 0.05) 100%);
  opacity: 0;
  transition: opacity var(--duration-normal);
}

.action-card:hover::before {
  opacity: 1;
}

.action-card:hover {
  transform: translateY(-8px) scale(1.02);
  border-color: rgba(233, 30, 99, 0.3);
  box-shadow: var(--card-hover-shadow);
}

.action-card:active {
  transform: translateY(-4px) scale(0.98);
}

.action-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: var(--surface-2);
  box-shadow: 0 4px 15px rgba(0,0,0,0.06);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-muted);
  font-size: 28px;
  transition: all var(--duration-normal) var(--ease-spring);
  position: relative;
  z-index: 1;
}

.action-icon::after {
  content: '';
  position: absolute;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: var(--primary-soft);
  opacity: 0;
  transform: scale(0.8);
  transition: all var(--duration-normal) var(--ease-spring);
}

.action-card:hover .action-icon::after {
  opacity: 1;
  transform: scale(1);
}

.action-card:hover .action-icon {
  color: var(--primary-pink);
  transform: scale(1.15) rotate(10deg);
  box-shadow: 0 6px 20px rgba(236, 64, 122, 0.2);
}

.action-icon .material-symbols-rounded {
  position: relative;
  z-index: 2;
  transition: transform var(--duration-normal) var(--ease-spring);
}

.action-card:hover .action-icon .material-symbols-rounded {
  animation: iconWiggle 0.5s var(--ease-spring);
}

.action-label {
  font-weight: 600;
  color: var(--text-dark);
  font-size: 1rem;
  position: relative;
  z-index: 1;
  transition: color var(--duration-fast);
}

.action-card:hover .action-label {
  color: var(--primary-pink);
}

.action-desc {
  font-size: 0.8rem;
  color: var(--text-muted);
  position: relative;
  z-index: 1;
}

/* --- Detail Modal --- */
.detail-modal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.5);
  backdrop-filter: blur(4px);
  z-index: 2000;
  align-items: center;
  justify-content: center;
}

.detail-modal.show {
  display: flex;
}

.detail-modal-content {
  background: #fff;
  border-radius: var(--radius-lg);
  width: 90%;
  max-width: 700px;
  max-height: 80vh;
  overflow: hidden;
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from { transform: translateY(50px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

.detail-modal-header {
  padding: 24px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.detail-modal-header h3 {
  margin: 0;
  font-size: 1.25rem;
  color: var(--text-dark);
}

.detail-modal-close {
  background: none;
  border: none;
  cursor: pointer;
  color: var(--text-muted);
  padding: 8px;
  border-radius: 50%;
  display: flex;
  transition: all 0.2s;
}

.detail-modal-close:hover {
  background: #f0f0f0;
  color: var(--text-dark);
}

.detail-modal-body {
  padding: 24px;
  max-height: 60vh;
  overflow-y: auto;
}

.detail-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.detail-item {
  display: flex;
  align-items: center;
  padding: 16px;
  border-radius: 12px;
  transition: background 0.2s;
  gap: 16px;
}

.detail-item:hover {
  background: #f8f9fc;
}

.detail-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: var(--primary-soft);
  color: var(--primary-pink);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  flex-shrink: 0;
}

.detail-info {
  flex: 1;
}

.detail-name {
  font-weight: 600;
  color: var(--text-dark);
  margin-bottom: 4px;
}

.detail-meta {
  font-size: 0.85rem;
  color: var(--text-muted);
}

.detail-badge {
  padding: 6px 12px;
  border-radius: 50px;
  font-size: 0.8rem;
  font-weight: 600;
}

.badge-late {
  background: rgba(255, 152, 0, 0.1);
  color: #FF9800;
}

.badge-absent {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}

.badge-present {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

/* Dark Mode */
[data-theme="dark"] .dashboard-container {
    --bg-soft: #121212;
    --text-dark: #ecf0f1;
    --text-muted: #b0bec5;
    --surface-1: #1E1E1E;
    --surface-2: #2C2C2C;
    --surface-3: #3D3D3D;
    --card-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
    --card-hover-shadow: 0 8px 30px rgba(236, 64, 122, 0.2), 0 4px 12px rgba(0, 0, 0, 0.3);
}

[data-theme="dark"] .welcome-banner {
    background: linear-gradient(135deg, #300020 0%, #1a0010 100%);
    border-color: rgba(255,255,255,0.1);
}

[data-theme="dark"] .welcome-text h1 { color: #F48FB1; }
[data-theme="dark"] .welcome-text p { color: #F8BBD0; }
[data-theme="dark"] .date-badge { 
    background: var(--surface-2); 
    color: #CE93D8;
}

[data-theme="dark"] .kpi-card, 
[data-theme="dark"] .chart-card, 
[data-theme="dark"] .action-card, 
[data-theme="dark"] .filter-bar {
    background: var(--surface-1);
    border-color: rgba(255,255,255,0.05);
}

[data-theme="dark"] .kpi-card:hover,
[data-theme="dark"] .chart-card:hover,
[data-theme="dark"] .action-card:hover {
    background: var(--surface-2);
}

[data-theme="dark"] .kpi-icon-wrapper { background: rgba(255,255,255,0.08); }
[data-theme="dark"] .kpi-action { border-top-color: rgba(255,255,255,0.1); }

[data-theme="dark"] .action-icon { 
    background: var(--surface-2); 
    box-shadow: 0 4px 15px rgba(0,0,0,0.2);
}
[data-theme="dark"] .action-icon::after { background: rgba(236, 64, 122, 0.15); }

[data-theme="dark"] .filter-btn { 
    background: var(--surface-2); 
    border-color: #444; 
    color: #b0bec5; 
}
[data-theme="dark"] .filter-btn:hover { 
    background: var(--surface-3); 
    border-color: var(--primary-pink);
}
[data-theme="dark"] .filter-btn.active { 
    background: var(--primary-pink); 
    border-color: var(--primary-pink); 
    color: #fff; 
}

[data-theme="dark"] .date-inputs input { 
    background: var(--surface-2); 
    border-color: #444; 
    color: #fff; 
}
[data-theme="dark"] .date-inputs input:focus { 
    border-color: var(--primary-pink);
    box-shadow: 0 0 0 4px rgba(236, 64, 122, 0.2);
}

/* Best Employee Card - Dark Mode Empty State */
[data-theme="dark"] .best-employee-card.empty {
    background: linear-gradient(135deg, #37474F 0%, #263238 100%);
    box-shadow: 0 8px 32px rgba(0,0,0,0.3);
}
[data-theme="dark"] .best-employee-card.empty h4 { color: rgba(255,255,255,0.85); }
[data-theme="dark"] .best-employee-card.empty .name { color: rgba(255,255,255,0.9); }
[data-theme="dark"] .best-employee-card.empty .stats { color: rgba(255,255,255,0.6); }

/* Chart cards in dark mode */
[data-theme="dark"] .section-title h3 { color: var(--text-dark); }
[data-theme="dark"] .empty-chart-placeholder {
    background: linear-gradient(180deg, var(--surface-2) 0%, var(--surface-1) 100%);
    border-color: #444;
}

[data-theme="dark"] .detail-modal-content { background: var(--surface-1); }
[data-theme="dark"] .detail-modal-header { border-bottom-color: rgba(255,255,255,0.1); }
[data-theme="dark"] .detail-item:hover { background: var(--surface-2); }
[data-theme="dark"] .detail-avatar { background: rgba(236, 64, 122, 0.15); }

/* Quick actions title in dark mode */
[data-theme="dark"] .quick-actions-title { color: var(--text-dark); }

@media (max-width: 1200px) {
  .charts-grid { grid-template-columns: 1fr; }
  .charts-row { grid-template-columns: 1fr 1fr; }
}

@media (max-width: 768px) {
  .charts-row { grid-template-columns: 1fr; }
  .filter-bar { flex-direction: column; align-items: stretch; }
  .date-inputs { margin-left: 0; margin-top: 12px; flex-wrap: wrap; }
}
</style>
</head>

<body>

<jsp:include page="../shared/session-saver.jsp"/>

<jsp:include page="../shared/session-saver.jsp"/>

<!-- Loading Screen -->
<jsp:include page="../shared/loading-screen.jsp"/>
<jsp:include page="../shared/console-warning.jsp"/>

<!-- Shared Sidebar & Header -->
<jsp:include page="../shared/sidebar.jsp"/>

<div class="main-content">
  <jsp:include page="../shared/header.jsp"/>

  <div class="dashboard-container">
    
    <!-- Welcome Banner -->
    <div class="welcome-banner">
      <div class="welcome-text">
        <h1>Hola, <span class="highlight-user">${sessionScope.usuario.nombres}</span></h1>
        <p>¿Qué te gustaría gestionar hoy?</p>
      </div>
      <div class="date-badge">
        <span class="material-symbols-rounded">calendar_today</span>
        <span id="currentDate">Fecha Actual</span>
      </div>
    </div>

    <!-- Date Filter Bar -->
    <div class="filter-bar">
      <label>
        <span class="material-symbols-rounded">filter_alt</span>
        Período:
      </label>
      <button class="filter-btn active" data-filter="HOY">Hoy</button>
      <button class="filter-btn" data-filter="SEMANA">Esta Semana</button>
      <button class="filter-btn" data-filter="MES">Este Mes</button>
      <button class="filter-btn" data-filter="AÑO">Este Año</button>
      <button class="filter-btn" data-filter="PERSONALIZADO">Personalizado</button>
      
      <div class="date-inputs" id="customDateInputs">
        <input type="date" id="fechaInicio" />
        <span>a</span>
        <input type="date" id="fechaFin" />
        <button class="apply-btn" onclick="applyCustomDateFilter()">Aplicar</button>
      </div>
    </div>

    <!-- KPI Cards -->
    <div class="kpi-grid">
      <!-- Total Empleados -->
      <div class="kpi-card kpi-green" onclick="openDetailModal('empleados')">
        <div class="kpi-header">
          <div class="kpi-icon-wrapper">
            <span class="material-symbols-rounded">group</span>
          </div>
        </div>
        <div class="kpi-value" id="kpiTotalEmpleados">${empty totalEmpleados ? '0' : totalEmpleados}</div>
        <div class="kpi-label">Total Empleados</div>
        <div class="kpi-action">Ver lista <span class="material-symbols-rounded" style="font-size:18px;">arrow_forward</span></div>
      </div>

      <!-- Inasistencias -->
      <div class="kpi-card kpi-orange" onclick="openDetailModal('inasistencias')">
        <div class="kpi-header">
          <div class="kpi-icon-wrapper">
            <span class="material-symbols-rounded">event_busy</span>
          </div>
        </div>
        <div class="kpi-value" id="kpiInasistencias">${empty inasistenciasHoy ? '0' : inasistenciasHoy}</div>
        <div class="kpi-label">Inasistencias</div>
        <div class="kpi-action">Ver detalles <span class="material-symbols-rounded" style="font-size:18px;">arrow_forward</span></div>
      </div>

      <!-- Tardanzas -->
      <div class="kpi-card kpi-purple" onclick="openDetailModal('tardanzas')">
        <div class="kpi-header">
          <div class="kpi-icon-wrapper">
            <span class="material-symbols-rounded">timer_off</span>
          </div>
        </div>
        <div class="kpi-value" id="kpiTardanzas">${empty tardanzasHoy ? '0' : tardanzasHoy}</div>
        <div class="kpi-label">Tardanzas</div>
        <div class="kpi-action">Ver detalles <span class="material-symbols-rounded" style="font-size:18px;">arrow_forward</span></div>
      </div>

      <!-- Justificaciones Pendientes -->
      <div class="kpi-card kpi-pink" onclick="location.href='${pageContext.request.contextPath}/justificaciones'">
        <div class="kpi-header">
          <div class="kpi-icon-wrapper">
            <span class="material-symbols-rounded">assignment_late</span>
          </div>
        </div>
        <div class="kpi-value" id="kpiJustificaciones">${empty justificacionesHoy ? '0' : justificacionesHoy}</div>
        <div class="kpi-label">Justificaciones Pendientes</div>
        <div class="kpi-action">Revisar <span class="material-symbols-rounded" style="font-size:18px;">arrow_forward</span></div>
      </div>

      <!-- Tasa de Puntualidad -->
      <div class="kpi-card kpi-blue">
        <div class="kpi-header">
          <div class="kpi-icon-wrapper">
            <span class="material-symbols-rounded">speed</span>
          </div>
        </div>
        <div class="kpi-value" id="kpiPuntualidad">${empty tasaPuntualidad ? '0' : tasaPuntualidad}%</div>
        <div class="kpi-label">Tasa de Puntualidad</div>
      </div>
    </div>

    <!-- Best Employee Card (Full Width) -->
    <div style="margin-bottom: 24px;">
      <div class="best-employee-card${empty mejorEmpleado ? ' empty' : ''}" id="bestEmployeeCard" style="display: flex; flex-direction: row; justify-content: space-between; align-items: center; padding: 32px 48px; text-align: left;">
        <c:choose>
          <c:when test="${not empty mejorEmpleado}">
            <div style="display: flex; align-items: center; gap: 24px;">
              <span class="material-symbols-rounded medal-icon" style="margin-bottom: 0;">emoji_events</span>
              <div>
                <h4 style="margin: 0; font-size: 1.1rem; opacity: 0.9;">Mejor Empleado del Período</h4>
                <div class="name" style="margin: 4px 0 0; font-size: 1.8rem;">${mejorEmpleado.nombres} ${mejorEmpleado.apellidos}</div>
              </div>
            </div>
            <div class="stats" style="font-size: 1.1rem; background: rgba(255,255,255,0.2); padding: 12px 24px; border-radius: 50px;">
              <span class="material-symbols-rounded">check_circle</span>
              ${mejorEmpleado.totalAsistencias} asistencias puntuales
            </div>
          </c:when>
          <c:otherwise>
            <div style="display: flex; align-items: center; gap: 24px;">
              <span class="material-symbols-rounded medal-icon" style="margin-bottom: 0;">hourglass_empty</span>
              <div>
                <h4 style="margin: 0; font-size: 1.1rem;">Mejor Empleado del Período</h4>
                <div class="name" style="margin: 4px 0 0; font-size: 1.5rem;">Sin datos aún</div>
              </div>
            </div>
            <div class="stats">
              <span class="material-symbols-rounded">info</span>
              Esperando registros de asistencia
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <!-- Main Chart: Tendencia de Asistencias (Full Row) -->
    <div class="chart-card" style="margin-bottom: 24px;">
      <div class="section-header">
        <div class="section-title">
          <h3>Tendencia de Asistencias (Últimos 7 días)</h3>
        </div>
      </div>
      <div class="chart-wrapper" id="mainChartWrapper" style="height: 350px;">
        <canvas id="asistenciaChart"></canvas>
      </div>
    </div>

    <!-- Second Row Charts (2 Columns) -->
    <div class="charts-row">
      <!-- Donut Chart: Solicitudes -->
      <div class="chart-card">
        <div class="section-header">
          <div class="section-title">
            <h3>Estado de Solicitudes</h3>
          </div>
        </div>
        <div class="chart-wrapper" style="height: 250px;">
          <canvas id="estadoChart"></canvas>
        </div>
      </div>

      <!-- Pie Chart: Modos de Asistencia -->
      <div class="chart-card">
        <div class="section-header">
          <div class="section-title">
            <h3>Métodos de Marcación</h3>
          </div>
        </div>
        <div class="chart-wrapper" style="height: 250px;">
          <canvas id="modosChart"></canvas>
        </div>
      </div>
    </div>

    <!-- Bar Chart: Asistencias vs Tardanzas (Full Row) -->
    <div class="chart-card" style="margin-bottom: 24px;">
      <div class="section-header">
        <div class="section-title">
          <h3>Asistencias vs Tardanzas</h3>
        </div>
      </div>
      <div class="chart-wrapper" style="height: 300px;">
        <canvas id="comparacionChart"></canvas>
      </div>
    </div>

    <!-- Quick Actions -->
    <h3 class="quick-actions-title">Accesos Rápidos</h3>
    <div class="actions-grid">
      
      <div class="action-card" onclick="openQrModal()">
        <div class="action-icon">
          <span class="material-symbols-rounded">qr_code_2</span>
        </div>
        <div class="action-label">Scanner QR</div>
        <div class="action-desc">Ingreso rápido</div>
      </div>

      <div class="action-card" onclick="location.href='${pageContext.request.contextPath}/empleados'">
        <div class="action-icon">
          <span class="material-symbols-rounded">badge</span>
        </div>
        <div class="action-label">Empleados</div>
        <div class="action-desc">Directorio</div>
      </div>

       <div class="action-card" onclick="location.href='${pageContext.request.contextPath}/justificaciones'">
        <div class="action-icon">
          <span class="material-symbols-rounded">assignment_ind</span>
        </div>
        <div class="action-label">Justificar</div>
        <div class="action-desc">Revisar pedidos</div>
      </div>

       <div class="action-card" onclick="location.href='${pageContext.request.contextPath}/horarios'">
        <div class="action-icon">
          <span class="material-symbols-rounded">schedule</span>
        </div>
        <div class="action-label">Horarios</div>
        <div class="action-desc">Programación</div>
      </div>

    </div>

  </div> <!-- End Container -->
</div> <!-- End Main Content -->

<!-- Detail Modal -->
<div class="detail-modal" id="detailModal">
  <div class="detail-modal-content">
    <div class="detail-modal-header">
      <h3 id="detailModalTitle">Detalles</h3>
      <button class="detail-modal-close" onclick="closeDetailModal()">
        <span class="material-symbols-rounded">close</span>
      </button>
    </div>
    <div class="detail-modal-body">
      <div id="detailModalLoading" class="empty-state">
        <span class="material-symbols-rounded">hourglass_empty</span>
        <h4>Cargando...</h4>
      </div>
      <ul class="detail-list" id="detailModalList" style="display:none;"></ul>
      <div id="detailModalEmpty" class="empty-state" style="display:none;">
        <span class="material-symbols-rounded">inbox</span>
        <h4>Sin registros</h4>
        <p>No hay datos para mostrar en este período.</p>
      </div>
    </div>
  </div>
</div>

<!-- QR Modal -->
<div id="qrModal" class="modal-overlay" style="display: none;">
  <div class="modal-content">
    <button class="close-btn" onclick="closeQrModal()">
      <span class="material-symbols-rounded">close</span>
    </button>
    
    <div class="qr-header">
      <div class="icon-badge">
        <span class="material-symbols-rounded">qr_code_Scanner</span>
      </div>
      <h2>Punto de Asistencia</h2>
      <p>Escanea para registrar tu entrada</p>
    </div>
    
    <div class="qr-card">
       <div id="qrcode-container"></div>
    </div>
      
    <div class="status-pill">
      <div class="spinner-ring"></div>
      <span id="qrStatusText">Sincronizando...</span>
    </div>

    <!-- Success Overlay -->
    <div id="successOverlay" class="success-overlay" style="display: none;">
      <div class="success-content">
        <div class="success-ring">
            <span class="material-symbols-rounded">check</span>
        </div>
        <h3 id="successTitle">¡Marcado!</h3>
        
        <div class="user-card-mini">
          <div class="avatar-circle">
             <span class="material-symbols-rounded">person</span>
          </div>
          <div class="user-info">
            <span id="userName" class="user-name">Nombre Empleado</span>
            <span id="userTime" class="user-time">00:00 AM</span>
          </div>
        </div>
      </div>
    </div>

  </div>
</div>

<style>
/* QR Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.4);
  backdrop-filter: blur(8px);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-content {
  background: #fff;
  padding: 48px;
  border-radius: 32px;
  width: 90%;
  max-width: 420px;
  text-align: center;
  position: relative;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  animation: slideUpFade 0.5s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes slideUpFade {
  from { transform: translateY(40px) scale(0.95); opacity: 0; }
  to { transform: translateY(0) scale(1); opacity: 1; }
}

.close-btn {
  position: absolute;
  top: 20px;
  right: 20px;
  background: transparent;
  border: none;
  cursor: pointer;
  color: var(--text-muted);
  padding: 8px;
  border-radius: 50%;
  display: flex;
  transition: all 0.2s;
}
.close-btn:hover { 
    background: rgba(128,128,128,0.1); 
    color: var(--text-dark);
    transform: rotate(90deg);
}

.qr-header { margin-bottom: 32px; }

.icon-badge {
    width: 64px;
    height: 64px;
    background: linear-gradient(135deg, #e91e63 0%, #ff4081 100%);
    border-radius: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 20px;
    color: white;
    box-shadow: 0 10px 20px rgba(233, 30, 99, 0.3);
}
.icon-badge span { font-size: 32px; }

.modal-content h2 {
  color: var(--text-dark);
  margin: 0 0 8px;
  font-weight: 700;
  font-size: 1.5rem;
}

.qr-header p {
  color: var(--text-muted);
  margin: 0;
  font-size: 1rem;
}

.qr-card {
    background: white;
    padding: 24px;
    border-radius: 24px;
    display: inline-block;
    box-shadow: inset 0 2px 10px rgba(0,0,0,0.05);
    margin-bottom: 32px;
    border: 4px solid #e0e0e0;
}

#qrcode-container img { margin: 0 auto; display: block; }

.status-pill {
  background: #f1f5f9;
  color: #475569;
  padding: 10px 20px;
  border-radius: 50px;
  display: inline-flex;
  align-items: center;
  gap: 12px;
  font-size: 0.9rem;
  font-weight: 600;
}

.spinner-ring {
    width: 16px;
    height: 16px;
    border: 2px solid rgba(128,128,128,0.2);
    border-top-color: #e91e63;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.success-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(255,255,255,0.98);
  border-radius: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
}

.success-content {
    animation: scaleIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

@keyframes scaleIn {
  from { transform: scale(0.8); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}

.success-ring {
    width: 80px;
    height: 80px;
    background: #10b981;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    margin: 0 auto 24px;
    box-shadow: 0 10px 25px rgba(16, 185, 129, 0.4);
}
.success-ring span { font-size: 40px; font-weight: bold; }

.success-overlay h3 {
    color: var(--text-dark);
    font-size: 1.8rem;
    margin: 0 0 32px;
}

.user-card-mini {
    background: #f1f5f9;
    padding: 16px 24px;
    border-radius: 20px;
    display: flex;
    align-items: center;
    gap: 16px;
    text-align: left;
}

.avatar-circle {
    width: 48px;
    height: 48px;
    background: rgba(233, 30, 99, 0.1);
    color: #e91e63;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}

.user-time {
    font-size: 0.9rem;
    color: var(--text-muted);
}

[data-theme="dark"] .modal-content { background: #1E1E1E; }
[data-theme="dark"] .qr-card { border-color: #333; }
[data-theme="dark"] .status-pill { background: #2C2C2C; color: #e2e8f0; }
[data-theme="dark"] .success-overlay { background: rgba(30,30,30,0.98); }
[data-theme="dark"] .user-card-mini { background: #2C2C2C; }
</style>

<script>
// --- Global Variables ---
let currentFilter = 'HOY';
let chartAsistencia = null;
let chartEstado = null;
let chartModos = null;
let chartComparacion = null;

// Server Data
const serverData = {
    chartAsistencia: ${empty chartAsistencia ? '[0,0,0,0,0,0,0]' : chartAsistencia},
    chartTardanzas: ${empty chartTardanzas ? '[0,0,0,0,0,0,0]' : chartTardanzas},
    chartLabels: ${empty chartLabels ? '["Lun","Mar","Mié","Jue","Vie","Sáb","Dom"]' : chartLabels},
    chartSolicitudes: ${empty chartSolicitudes ? '[0,0,0]' : chartSolicitudes},
    chartModos: ${empty chartModos ? '{}' : chartModos}
};

// --- Date Logic ---
const dateElement = document.getElementById('currentDate');
const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
dateElement.textContent = new Date().toLocaleDateString('es-ES', options).replace(/^\w/, (c) => c.toUpperCase());

// --- Filter Logic ---
document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        this.classList.add('active');
        
        const filter = this.dataset.filter;
        currentFilter = filter;
        
        const customInputs = document.getElementById('customDateInputs');
        if (filter === 'PERSONALIZADO') {
            customInputs.classList.add('show');
        } else {
            customInputs.classList.remove('show');
            loadDashboardData(filter);
        }
    });
});

function applyCustomDateFilter() {
    const inicio = document.getElementById('fechaInicio').value;
    const fin = document.getElementById('fechaFin').value;
    if (inicio && fin) {
        loadDashboardData('PERSONALIZADO', inicio, fin);
    }
}

function loadDashboardData(tipo, fechaInicio = '', fechaFin = '') {
    let url = '${pageContext.request.contextPath}/dashboard/api/stats?tipo=' + tipo;
    if (fechaInicio) url += '&fechaInicio=' + fechaInicio;
    if (fechaFin) url += '&fechaFin=' + fechaFin;
    
    fetch(url)
        .then(res => res.json())
        .then(data => {
            if (!data) return;
            
            // Update KPIs with animation
            animateKPIUpdate('kpiTotalEmpleados', data.totalEmpleados || 0);
            animateKPIUpdate('kpiInasistencias', data.inasistenciasHoy || 0);
            animateKPIUpdate('kpiTardanzas', data.tardanzasHoy || 0);
            animateKPIUpdate('kpiJustificaciones', data.justificacionesPendientes || 0);
            animateKPIUpdate('kpiPuntualidad', (data.tasaPuntualidad || 0) + '%');
            
            // Update Best Employee
            const bestCard = document.getElementById('bestEmployeeCard');
            if (data.mejorEmpleado) {
                bestCard.classList.remove('empty');
                bestCard.innerHTML = `
                    <span class="material-symbols-rounded medal-icon">emoji_events</span>
                    <h4>Mejor Empleado del Período</h4>
                    <div class="name">\${data.mejorEmpleado.nombres} \${data.mejorEmpleado.apellidos}</div>
                    <div class="stats">
                      <span class="material-symbols-rounded">check_circle</span>
                      \${data.mejorEmpleado.totalAsistencias} asistencias puntuales
                    </div>
                `;
            } else {
                bestCard.classList.add('empty');
                bestCard.innerHTML = `
                    <span class="material-symbols-rounded medal-icon">hourglass_empty</span>
                    <h4>Mejor Empleado del Período</h4>
                    <div class="name">Sin datos aún</div>
                    <div class="stats">
                      <span class="material-symbols-rounded">info</span>
                      Esperando registros de asistencia
                    </div>
                `;
            }
            
            // Update Asistencia Chart
            if (chartAsistencia) {
                const asistenciaData = data.chartAsistenciaSemanal || [];
                const tardanzasData = data.chartTardanzasSemanal || [];
                chartAsistencia.data.datasets[0].data = asistenciaData;
                chartAsistencia.data.datasets[1].data = tardanzasData;
                if (data.chartLabels) chartAsistencia.data.labels = data.chartLabels;
                chartAsistencia.update('active');
            }
            
            // Update Modos Chart - FIX: Handle empty data properly
            if (chartModos) {
                const modos = data.chartDistribucionModos;
                if (modos && Object.keys(modos).length > 0 && Object.values(modos).some(v => v > 0)) {
                    // Has data
                    chartModos.data.labels = Object.keys(modos);
                    chartModos.data.datasets[0].data = Object.values(modos);
                    chartModos.data.datasets[0].backgroundColor = ['#E91E63', '#2196F3', '#4CAF50', '#FF9800', '#9C27B0'];
                    chartModos.options.plugins.tooltip.enabled = true;
                } else {
                    // No data - show empty state
                    chartModos.data.labels = ['Sin Datos'];
                    chartModos.data.datasets[0].data = [1];
                    chartModos.data.datasets[0].backgroundColor = ['#e0e0e0'];
                    chartModos.options.plugins.tooltip.enabled = false;
                }
                chartModos.update('active');
            }
            
            // Update Comparacion Chart
            if (chartComparacion) {
                const asistenciaData = data.chartAsistenciaSemanal || [];
                const tardanzasData = data.chartTardanzasSemanal || [];
                chartComparacion.data.datasets[0].data = asistenciaData;
                chartComparacion.data.datasets[1].data = tardanzasData;
                if (data.chartLabels) chartComparacion.data.labels = data.chartLabels;
                chartComparacion.update('active');
            }
            
            // Update Estado Chart
            if (chartEstado && data.chartSolicitudes) {
                const hasEstadoData = data.chartSolicitudes.some(v => v > 0);
                if (hasEstadoData) {
                    chartEstado.data.labels = ['Pendiente', 'Aprobado', 'Rechazado'];
                    chartEstado.data.datasets[0].data = data.chartSolicitudes;
                    chartEstado.data.datasets[0].backgroundColor = ['#FFB74D', '#81C784', '#E57373'];
                    chartEstado.options.plugins.tooltip.enabled = true;
                } else {
                    chartEstado.data.labels = ['Sin Datos'];
                    chartEstado.data.datasets[0].data = [1];
                    chartEstado.data.datasets[0].backgroundColor = ['#e0e0e0'];
                    chartEstado.options.plugins.tooltip.enabled = false;
                }
                chartEstado.update('active');
            }
        })
        .catch(err => console.error('Error loading dashboard data:', err));
}

// Animate KPI updates
function animateKPIUpdate(elementId, newValue) {
    const element = document.getElementById(elementId);
    if (!element) return;
    
    element.style.opacity = '0';
    element.style.transform = 'translateY(10px)';
    
    setTimeout(() => {
        element.textContent = newValue;
        element.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
        element.style.opacity = '1';
        element.style.transform = 'translateY(0)';
    }, 150);
}

// --- Chart Initialization ---
Chart.defaults.font.family = "'Outfit', sans-serif";
Chart.defaults.color = '#64748b';

function hasData(arr) {
    if (!arr) return false;
    return arr.some(val => val > 0);
}

// Chart 1: Line + Bar (Asistencias & Tardanzas)
const ctx1 = document.getElementById('asistenciaChart').getContext('2d');
const gradientFill = ctx1.createLinearGradient(0, 0, 0, 400);
gradientFill.addColorStop(0, 'rgba(233, 30, 99, 0.2)');
gradientFill.addColorStop(1, 'rgba(233, 30, 99, 0.0)');

chartAsistencia = new Chart(ctx1, {
  type: 'line',
  data: {
    labels: serverData.chartLabels,
    datasets: [{
      label: 'Asistencias',
      data: serverData.chartAsistencia,
      borderColor: '#E91E63',
      backgroundColor: gradientFill,
      borderWidth: 3,
      pointBackgroundColor: '#fff',
      pointBorderColor: '#E91E63',
      pointRadius: 5,
      pointHoverRadius: 7,
      fill: true,
      tension: 0.4
    }, {
      label: 'Tardanzas',
      data: serverData.chartTardanzas,
      borderColor: '#FF9800',
      backgroundColor: 'rgba(255, 152, 0, 0.1)',
      borderWidth: 2,
      pointBackgroundColor: '#fff',
      pointBorderColor: '#FF9800',
      pointRadius: 4,
      fill: false,
      tension: 0.4
    }]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: true, position: 'top' }
    },
    scales: {
      y: {
        beginAtZero: true,
        grid: { color: '#f0f0f0', borderDash: [5, 5] }
      },
      x: {
        grid: { display: false }
      }
    }
  }
});

// Chart 2: Doughnut (Solicitudes)
const ctx2 = document.getElementById('estadoChart').getContext('2d');
const isSolicitudesEmpty = !hasData(serverData.chartSolicitudes);

chartEstado = new Chart(ctx2, {
  type: 'doughnut',
  data: {
    labels: isSolicitudesEmpty ? ['Sin Datos'] : ['Pendiente', 'Aprobado', 'Rechazado'],
    datasets: [{
      data: isSolicitudesEmpty ? [1] : serverData.chartSolicitudes,
      backgroundColor: isSolicitudesEmpty ? ['#e0e0e0'] : ['#FFB74D', '#81C784', '#E57373'],
      borderWidth: 0,
      hoverOffset: 4
    }]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    cutout: '70%',
    plugins: {
      legend: { display: true, position: 'bottom' },
      tooltip: { enabled: !isSolicitudesEmpty }
    }
  }
});

// Chart 3: Pie (Modos de Asistencia)
const ctx3 = document.getElementById('modosChart').getContext('2d');
const modosLabels = Object.keys(serverData.chartModos);
const modosValues = Object.values(serverData.chartModos);
const isModosEmpty = modosLabels.length === 0 || !hasData(modosValues);

chartModos = new Chart(ctx3, {
  type: 'pie',
  data: {
    labels: isModosEmpty ? ['Sin Datos'] : modosLabels,
    datasets: [{
      data: isModosEmpty ? [1] : modosValues,
      backgroundColor: isModosEmpty ? ['#e0e0e0'] : ['#E91E63', '#2196F3', '#4CAF50', '#FF9800', '#9C27B0'],
      borderWidth: 2,
      borderColor: '#fff'
    }]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: true, position: 'bottom' },
      tooltip: { enabled: !isModosEmpty }
    }
  }
});

// Chart 4: Bar (Comparison)
const ctx4 = document.getElementById('comparacionChart').getContext('2d');

chartComparacion = new Chart(ctx4, {
  type: 'bar',
  data: {
    labels: serverData.chartLabels,
    datasets: [{
      label: 'Asistencias',
      data: serverData.chartAsistencia,
      backgroundColor: 'rgba(233, 30, 99, 0.8)',
      borderRadius: 8
    }, {
      label: 'Tardanzas',
      data: serverData.chartTardanzas,
      backgroundColor: 'rgba(255, 152, 0, 0.8)',
      borderRadius: 8
    }]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: true, position: 'top' }
    },
    scales: {
      y: {
        beginAtZero: true,
        grid: { color: '#f0f0f0' }
      },
      x: {
        grid: { display: false }
      }
    }
  }
});

// --- Detail Modal ---
function openDetailModal(type) {
    document.getElementById('detailModal').classList.add('show');
    document.getElementById('detailModalLoading').style.display = 'flex';
    document.getElementById('detailModalList').style.display = 'none';
    document.getElementById('detailModalEmpty').style.display = 'none';
    
    let title = '';
    let url = '${pageContext.request.contextPath}/dashboard/api/detalle/';
    
    switch(type) {
        case 'empleados':
            title = 'Lista de Empleados';
            url = '${pageContext.request.contextPath}/empleados';
            window.location.href = url;
            return;
        case 'inasistencias':
            title = 'Empleados Ausentes';
            url += 'inasistencias';
            break;
        case 'tardanzas':
            title = 'Empleados con Tardanza';
            url += 'tardanzas';
            break;
        case 'asistencias':
            title = 'Asistencias del Día';
            url += 'asistencias';
            break;
    }
    
    document.getElementById('detailModalTitle').textContent = title;
    
    fetch(url)
        .then(res => res.json())
        .then(data => {
            document.getElementById('detailModalLoading').style.display = 'none';
            
            if (!data || data.length === 0) {
                document.getElementById('detailModalEmpty').style.display = 'flex';
                return;
            }
            
            const list = document.getElementById('detailModalList');
            list.innerHTML = '';
            
            data.forEach(item => {
                const li = document.createElement('li');
                li.className = 'detail-item';
                
                const nombre = item.nombres ? item.nombres + ' ' + item.apellidos : item.empleadoNombre + ' ' + item.empleadoApellido;
                const dni = item.dni || item.empleadoDni || '';
                const tardanza = item.minutosTardanza || 0;
                
                let badgeClass = 'badge-present';
                let badgeText = 'Presente';
                
                if (type === 'inasistencias') {
                    badgeClass = 'badge-absent';
                    badgeText = 'Ausente';
                } else if (type === 'tardanzas' && tardanza > 0) {
                    badgeClass = 'badge-late';
                    badgeText = tardanza + ' min tarde';
                }
                
                li.innerHTML = `
                    <div class="detail-avatar">
                        <span class="material-symbols-rounded">person</span>
                    </div>
                    <div class="detail-info">
                        <div class="detail-name">\${nombre}</div>
                        <div class="detail-meta">DNI: \${dni}</div>
                    </div>
                    <span class="detail-badge \${badgeClass}">\${badgeText}</span>
                `;
                list.appendChild(li);
            });
            
            list.style.display = 'block';
        })
        .catch(err => {
            console.error('Error loading details:', err);
            document.getElementById('detailModalLoading').style.display = 'none';
            document.getElementById('detailModalEmpty').style.display = 'flex';
        });
}

function closeDetailModal() {
    document.getElementById('detailModal').classList.remove('show');
}

// Close modal on outside click
document.getElementById('detailModal').addEventListener('click', function(e) {
    if (e.target === this) closeDetailModal();
});

// --- QR Modal ---
let qrInterval;
let pollInterval;
let qrCodeObj = null;
let lastAttendanceId = 0;

function openQrModal() {
  document.getElementById('qrModal').style.display = 'flex';
  
  if (!qrCodeObj) {
      qrCodeObj = new QRCode(document.getElementById("qrcode-container"), {
          width: 220,
          height: 220,
          colorDark : "#000000",
          colorLight : "#ffffff",
          correctLevel : QRCode.CorrectLevel.H
      });
  }
  
  updateQR();
  qrInterval = setInterval(updateQR, 30000);
  
  fetchLatestAttendance(true);
  pollInterval = setInterval(() => fetchLatestAttendance(false), 2000); 
}

function closeQrModal() {
  document.getElementById('qrModal').style.display = 'none';
  clearInterval(qrInterval);
  clearInterval(pollInterval);
  document.getElementById('successOverlay').style.display = 'none';
}

function updateQR() {
    var fechaHoy = new Date().toISOString().split('T')[0];
    var tokenSecreto = "GRUPO_PERUANA_" + fechaHoy;
    qrCodeObj.clear(); 
    qrCodeObj.makeCode(tokenSecreto);
}

function fetchLatestAttendance(isInitial) {
    fetch('${pageContext.request.contextPath}/admin/api/ultima-asistencia')
        .then(response => {
            if (!response.ok) return null;
            return response.json();
        })
        .then(data => {
            if (!data || !data.id) return;
            
            if (isInitial) {
                lastAttendanceId = data.id;
            } else {
                if (data.id > lastAttendanceId) {
                    lastAttendanceId = data.id;
                    showSuccess(data);
                }
            }
        })
        .catch(err => console.error("Polling error:", err));
}

function showSuccess(data) {
    const overlay = document.getElementById('successOverlay');
    const title = document.getElementById('successTitle');
    const name = document.getElementById('userName');
    const time = document.getElementById('userTime');
    
    const action = (data.horaSalida && data.horaSalida !== "") ? "Salida" : "Entrada";
    title.innerText = "¡" + action + " Registrada!";
    
    if(data.empleado) {
        name.innerText = data.empleado.nombres + " " + data.empleado.apellidos;
    } else {
        name.innerText = "Empleado";
    }
    time.innerText = (data.horaSalida && data.horaSalida !== "") ? data.horaSalida : data.horaEntrada;
    
    overlay.style.display = 'flex';
    
    setTimeout(() => {
        overlay.style.display = 'none';
    }, 4000);
}
</script>

</body>
</html>
