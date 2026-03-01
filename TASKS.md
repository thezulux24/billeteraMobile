# Master Taskboard - billeteraMobile

Ultima actualizacion: 2026-02-28  
Objetivo: listar TODAS las tareas necesarias para completar la app segun SRS (`SRS_app_finanzas.md`) y plan modular (`modulos_y_tareas_app_finanzas.md`).

## Leyenda de estado

- `TODO`: no iniciado
- `DOING`: en progreso
- `BLOCKED`: bloqueado por dependencia externa
- `DONE`: completado y validado

## Estado global rapido

| Bloque | Estado | Notas |
| --- | --- | --- |
| Android debug base | DONE | `flutter analyze`, `flutter test`, `flutter build apk --debug`, `flutter run` OK |
| Migraciones base `0001-0004` | DONE | `Applied: 4`, `Pending: 0` |
| Auth + Profile base | DONE | Login/registro/recuperacion/sesion persistida |
| Assets base (cash + bank + credit) | DONE | CRUD principal en backend + UI principal |
| Transacciones base | DOING | `GET/POST/PATCH/DELETE` y filtros backend listos; falta cierre UI + integración |
| Dashboard real + Presupuestos | TODO | UI actual con partes mock/static |
| Amortizacion / IA / Premium | TODO | No iniciado |

---

## M0 - Fundaciones, Infra y Arquitectura (P0)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M0-001 | Estructura repo `mobile/` + `api/` + convenciones | P0 | DONE | Estructura activa en repo |
| M0-002 | Build Android local estable (Gradle/Flutter) | P0 | DONE | Gate Android ya cerrado |
| M0-003 | Configurar variables de entorno (`.env`, `dart-define`) | P0 | DONE | Flujo actual operativo |
| M0-004 | CI backend: lint + test + build check | P0 | TODO | Falta pipeline automatizado |
| M0-005 | CI mobile: analyze + test + build android/ios | P0 | TODO | Falta pipeline automatizado |
| M0-006 | Pipeline release Android (internal testing) | P0 | TODO | No configurado |
| M0-007 | Pipeline release iOS (TestFlight) | P0 | TODO | No configurado |
| M0-008 | Entornos dev/stage/prod claros | P0 | TODO | Falta separacion formal |
| M0-009 | Feature flags base (tabla + uso en app) | P1 | TODO | No implementado |
| M0-010 | Crash reporting / analytics de app | P1 | TODO | No implementado |

---

## M1 - Autenticacion y Perfil (P0)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M1-001 | Sign-up email/password | P0 | DONE | Endpoint + UI activos |
| M1-002 | Sign-in email/password | P0 | DONE | Endpoint + UI activos |
| M1-003 | Refresh token en cliente | P0 | DONE | Interceptor/API client |
| M1-004 | Recuperar password | P0 | DONE | Endpoint + pantalla activos |
| M1-005 | Logout seguro | P0 | DONE | Flujo activo |
| M1-006 | Guard de rutas autenticadas | P0 | DONE | GoRouter redirect activo |
| M1-007 | Perfil base (moneda + IA toggle) | P0 | DONE | Endpoint + notifier activos |
| M1-008 | Validaciones robustas auth (UX) | P0 | DONE | Validacion frontend aplicada |
| M1-009 | OAuth Google/Apple | P1 | TODO | No implementado |
| M1-010 | Biometria (iOS + Android) | P2 | TODO | No implementado |
| M1-011 | Eliminacion de cuenta y limpieza de sesion | P1 | TODO | No implementado |

---

## M2 - Modelo de Datos, Migraciones, RLS y Soft Delete (P0)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M2-001 | Migracion `0001_auth_profiles.sql` | P0 | DONE | Aplicada |
| M2-002 | Migracion `0002_finance_core.sql` | P0 | DONE | Aplicada |
| M2-003 | Migracion `0003_credit_card_fields.sql` | P0 | DONE | Aplicada |
| M2-004 | Definir migracion `0004_financial_integrity.sql` | P0 | DONE | Aplicada en DB (`Applied: 4`, `Pending: 0`) |
| M2-005 | Agregar tablas `budgets` y `budget_alerts` | P0 | TODO | Requerido por SRS |
| M2-006 | Agregar tablas `amortization_plans` y `amortization_schedule` | P1 | TODO | Requerido por SRS |
| M2-007 | Agregar tablas `ai_chat_sessions` y `ai_chat_messages` | P1 | TODO | Requerido por SRS |
| M2-008 | RLS completo para tablas nuevas | P0 | TODO | Falta al crear M2-005/006/007 |
| M2-009 | Soft delete consistente en tablas nuevas | P0 | TODO | Falta al crear M2-005/006/007 |
| M2-010 | Indices para consultas analiticas | P0 | TODO | Falta para dashboard/budgets |
| M2-011 | Vistas agregadas (`v_balances`, gasto mensual por categoria) | P1 | TODO | No implementado |
| M2-012 | Flujo restore (papelera) | P2 | TODO | No implementado |

---

## M3 - Gestion de Activos (Cash + Bank) (P0)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M3-001 | Backend CRUD cash wallets | P0 | DONE | Endpoints y servicios activos |
| M3-002 | Backend CRUD bank accounts | P0 | DONE | Endpoints y servicios activos |
| M3-003 | Frontend alta/listado/eliminacion cash | P0 | DONE | Integrado en app |
| M3-004 | Frontend alta/listado/eliminacion bank | P0 | DONE | Integrado en app |
| M3-005 | Edicion de cash wallet en UI | P0 | TODO | Endpoint existe, UX incompleta |
| M3-006 | Edicion de bank account en UI | P0 | TODO | Endpoint existe, UX incompleta |
| M3-007 | Transferencias internas entre activos | P1 | TODO | Requiere motor transaccional |
| M3-008 | Validaciones de saldo insuficiente en transferencias | P0 | TODO | Pendiente con motor |

---

## M4 - Tarjetas de Credito y Deuda (P0)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M4-001 | Backend CRUD credit cards | P0 | DONE | Endpoints activos |
| M4-002 | Frontend alta/listado/eliminacion credit cards | P0 | DONE | Integrado en wallet |
| M4-003 | Edicion de tarjeta en UI | P0 | TODO | Endpoint existe, UX incompleta |
| M4-004 | Soportar `last_four` y `card_provider` en todo el flujo | P0 | DOING | Migracion lista, validar UI end-to-end |
| M4-005 | Reglas deuda: `credit_charge` no baja activos | P0 | DONE | Trigger financiero aplicado en `0004` |
| M4-006 | Reglas deuda: `credit_payment` baja deuda y activos | P0 | DONE | Trigger financiero aplicado en `0004` |
| M4-007 | Fechas de corte y pago + recordatorios | P1 | TODO | No implementado |
| M4-008 | Simulador pago minimo/total | P2 | TODO | Premium futuro |

---

## M5 - Transacciones + Categorias + Motor de Integridad (P0)

### M5-A Categorias

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M5-001 | Listar categorias (sistema + usuario) | P0 | DONE | Endpoint + app activos |
| M5-002 | Crear categoria personalizada | P0 | DONE | Endpoint + app activos |
| M5-003 | Eliminar categoria (soft delete) | P0 | DONE | Endpoint activo |
| M5-004 | Editar categoria (PATCH) | P0 | TODO | Falta endpoint y UI |
| M5-005 | Seed de categorias base en DB | P0 | TODO | Hoy hay base local predefinida |
| M5-006 | Archivar/restaurar categorias | P1 | TODO | No implementado |

### M5-B Transacciones (CRUD + filtros)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M5-101 | Listar transacciones | P0 | DONE | `GET /transactions` |
| M5-102 | Crear transaccion | P0 | DONE | `POST /transactions` |
| M5-103 | Editar transaccion (`PATCH`) | P0 | DOING | Endpoint + servicio + data layer mobile listos; falta UI end-to-end |
| M5-104 | Eliminar transaccion (`DELETE` soft) | P0 | DOING | Endpoint + servicio + data layer mobile listos; falta UI end-to-end |
| M5-105 | Filtros por fecha/categoria/fuente | P0 | DOING | Backend + notifier mobile listos; falta UI de filtros |
| M5-106 | Paginacion y carga incremental robusta | P1 | TODO | Parcial |
| M5-107 | Adjuntos recibos (storage) | P1 | TODO | No implementado |
| M5-108 | Reglas de categorizacion automatica | P2 | TODO | Premium futuro |

### M5-C Motor de integridad financiera (BLOQUE ACTIVO)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| F-000 | Verificar migraciones listas para arrancar | P0 | DONE | `Applied: 4`, `Pending: 0` |
| F-001 | Definir matriz de reglas por `kind` (origen/destino/impacto) | P0 | DONE | Implementada en validaciones schema + trigger DB |
| F-002 | Crear migracion `0004_financial_integrity.sql` | P0 | DONE | Constraints, validaciones y triggers de efectos |
| F-003 | Validaciones schema por tipo (`TransactionCreateRequest`) | P0 | DONE | Reglas por `kind` + normalizacion de moneda |
| F-004 | Aplicar efectos al crear transaccion | P0 | DONE | Trigger `after insert` ajusta saldos/deuda |
| F-005 | Reversa + reaplicacion al editar transaccion | P0 | DONE | Trigger `after update` revierte y reaplica |
| F-006 | Reversa al eliminar transaccion (soft delete) | P0 | DONE | `deleted_at` revierte efecto financiero |
| F-007 | Manejo de errores de integridad y mensajes claros | P0 | DOING | Backend devuelve errores; falta mapeo UX uniforme en app |
| F-008 | Tests unitarios del motor (`transaction_service`) | P0 | DONE | `api/tests/test_transaction_service.py` agregado |
| F-009 | Tests de integracion API transacciones | P0 | DONE | `api/tests/test_transaction_endpoint.py` agregado |
| F-010 | Refresco automatico de providers en app tras cambios | P0 | DOING | Notifier transacciones actualizado; falta sincronia Home/Wallet/Analytics |
| F-011 | Gate de calidad bloque F | P0 | DOING | `pytest` + `flutter analyze` + `flutter test` OK; falta E2E manual |

---

## M6 - Presupuestos y Alertas (P0)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M6-001 | Modelo DB presupuestos (`budgets`) | P0 | TODO | Pendiente migracion |
| M6-002 | Modelo DB alertas (`budget_alerts`) | P0 | TODO | Pendiente migracion |
| M6-003 | CRUD backend presupuestos | P0 | TODO | No implementado |
| M6-004 | Endpoint progreso mensual por categoria | P0 | TODO | No implementado |
| M6-005 | Regla alerta 80%/100% sin spam | P0 | TODO | No implementado |
| M6-006 | UI crear/editar presupuesto | P0 | TODO | No implementado |
| M6-007 | UI progreso y alertas en app | P0 | TODO | No implementado |
| M6-008 | Notificaciones push para alertas | P1 | TODO | No implementado |

---

## M7 - Dashboard, Analytics e Insights (P0)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M7-001 | Endpoint `GET /dashboard` con agregados reales | P0 | TODO | No existe aun |
| M7-002 | Total activos/deuda/net worth calculado en backend | P0 | TODO | Hoy se mezcla logica en frontend |
| M7-003 | Resumen mensual ingresos/egresos | P0 | TODO | No implementado |
| M7-004 | Top categorias de gasto | P0 | TODO | No implementado |
| M7-005 | Comparacion mes anterior | P0 | TODO | No implementado |
| M7-006 | Analytics screen consumiendo datos reales | P0 | TODO | Hoy esta mock/static |
| M7-007 | Filtros de periodo (mes/rango) | P0 | TODO | No implementado |
| M7-008 | Insights por reglas (no IA) | P1 | TODO | No implementado |
| M7-009 | Mejorar `trend` real en wallet summary card | P1 | TODO | Hay TODO en UI |

---

## M8 - Amortizacion (P1)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M8-001 | Migraciones `amortization_plans` + `amortization_schedule` | P1 | TODO | No implementado |
| M8-002 | Servicio de calculo metodo frances | P1 | TODO | No implementado |
| M8-003 | Endpoint crear plan y generar schedule | P1 | TODO | No implementado |
| M8-004 | Endpoint marcar cuota pagada | P1 | TODO | No implementado |
| M8-005 | Crear transaccion automatica al pagar cuota | P1 | TODO | No implementado |
| M8-006 | UI crear plan | P1 | TODO | No implementado |
| M8-007 | UI tabla schedule | P1 | TODO | No implementado |
| M8-008 | Abonos extra y recalculo | P2 | TODO | No implementado |

---

## M9 - Asistente IA (P1)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M9-001 | Seleccionar proveedor IA y llaves | P1 | TODO | No implementado |
| M9-002 | Endpoint `/ai/chat` con contexto agregado | P1 | TODO | No implementado |
| M9-003 | Rate limiting por usuario | P1 | TODO | No implementado |
| M9-004 | Modo privacidad (`AGGREGATES_ONLY`/`FULL`) | P1 | TODO | No implementado |
| M9-005 | Persistencia sesiones/mensajes IA | P1 | TODO | No implementado |
| M9-006 | UI chat + quick prompts | P1 | TODO | No implementado |
| M9-007 | Logs/trazabilidad sin datos sensibles | P1 | TODO | No implementado |
| M9-008 | Insights IA en dashboard | P2 | TODO | Premium futuro |

---

## M10 - Premium y Pagos (P1)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M10-001 | Definir plan premium y limites funcionales | P1 | TODO | No implementado |
| M10-002 | Modelo de suscripcion y estado premium | P1 | TODO | No implementado |
| M10-003 | Integrar pagos in-app (Android/iOS) | P1 | TODO | No implementado |
| M10-004 | Verificacion de recibos en backend | P1 | TODO | No implementado |
| M10-005 | Feature gating en frontend/backend | P1 | TODO | No implementado |
| M10-006 | Export CSV/PDF (premium) | P2 | TODO | No implementado |
| M10-007 | Dashboards avanzados premium | P2 | TODO | No implementado |
| M10-008 | IA avanzada premium | P2 | TODO | No implementado |

---

## M11 - QA, Observabilidad, Seguridad y Release (P0)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M11-001 | Tests backend para `credit_cards` | P0 | TODO | Falta cobertura dedicada |
| M11-002 | Tests backend para `categories` | P0 | TODO | Falta cobertura dedicada |
| M11-003 | Tests backend para `transactions` + motor | P0 | DOING | Tests de servicio + endpoint agregados; faltan pruebas con DB real |
| M11-004 | Tests widget de flujos criticos mobile | P0 | TODO | Cobertura muy baja actual |
| M11-005 | Manejo uniforme de errores y estados vacios | P0 | DOING | Parcial en app |
| M11-006 | Logging estructurado backend | P0 | DONE | Base implementada |
| M11-007 | Hardening seguridad (RLS/tokens/CORS/rate limit IA) | P0 | TODO | Falta cierre formal |
| M11-008 | Smoke test release Android (device real + emu) | P0 | TODO | Solo debug actual |
| M11-009 | Smoke test release iOS (sim + device) | P0 | TODO | Pendiente |
| M11-010 | Performance target dashboard `< 2s` | P0 | TODO | Medicion no cerrada |

---

## M12 - UI/UX Liquid Glass + Paridad iOS/Android (P0 transversal)

| ID | Tarea | Prioridad | Estado | Evidencia / Nota |
| --- | --- | --- | --- | --- |
| M12-001 | Design system base (colores, tipografia, radios, sombras) | P0 | DOING | Parcial implementado |
| M12-002 | Unificar headers de tabs principales | P0 | DONE | Home/Analytics/Wallet/Settings unificados |
| M12-003 | Unificar bottom sheets (new transaction/new account) | P0 | DOING | Ajustes recientes en curso |
| M12-004 | Estados loading/skeleton/empty premium | P0 | TODO | Falta cobertura completa |
| M12-005 | Validar touch targets (44/48dp) | P0 | TODO | Falta auditoria formal |
| M12-006 | Auditoria accesibilidad (contraste/focus/labels) | P0 | TODO | Falta auditoria formal |
| M12-007 | Soporte `prefers-reduced-motion`/animaciones seguras | P1 | TODO | No implementado |
| M12-008 | QA responsive mobile pequeno/grande | P0 | TODO | Falta pase completo |
| M12-009 | Paridad funcional iOS vs Android (feature por feature) | P0 | TODO | Falta matriz de validacion |
| M12-010 | Notificaciones y biometria en ambas plataformas | P1 | TODO | Pendiente |

---

## Orden recomendado desde hoy

| Orden | Bloque | Resultado esperado |
| --- | --- | --- |
| 1 | F-001 -> F-011 (motor integridad financiera) | Saldos/deuda 100% consistentes |
| 2 | M6 (presupuestos + alertas) | Control de gasto mensual funcional |
| 3 | M7 (dashboard real + analytics real) | Fin de datos mock y metricas reales |
| 4 | M11-001/002/003/004 | Cobertura de pruebas en modulos criticos |
| 5 | M8 (amortizacion) | Planes y schedule funcionando |
| 6 | M9 (IA basica) | Asistente contextual operativo |
| 7 | M10 (premium/pagos) | Monetizacion y gating |
| 8 | Cierre M12 + release gates | App lista para produccion |

---

## Release Gate final (debe quedar TODO en DONE antes de salir)

- [ ] Integridad financiera validada para todos los tipos de transaccion
- [ ] Presupuestos y alertas 80/100% operando sin spam
- [ ] Dashboard y analytics sin datos mock
- [ ] Amortizacion funcional minima (metodo frances)
- [ ] IA con control de privacidad y rate limit
- [ ] Feature gating premium estable
- [ ] RLS/soft delete auditado en todas las tablas
- [ ] Suite de pruebas backend/mobile para flujos criticos
- [ ] Smoke release iOS y Android en dispositivos reales
- [ ] Performance y UX final validados (SRS)
