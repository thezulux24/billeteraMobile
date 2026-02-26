# Checklist Multiplataforma (iOS + Android)

## 1. Antes de implementar
- Mapear la tarea al módulo (`M0` a `M12`) y definir prioridad (`P0` a `P3`).
- Confirmar si la funcionalidad toca integraciones nativas: biometría, notificaciones push o compras in-app.
- Definir criterios de aceptación con paridad funcional entre iOS y Android.

## 2. Durante la implementación
- Mantener lógica de negocio consistente entre UI, dominio y backend.
- Adaptar UX por plataforma solo cuando aporte valor nativo, sin romper la coherencia visual.
- Evitar divergencias funcionales entre plataformas para una misma feature.

## 3. Antes de cerrar
- Validar flujo principal en iOS y Android.
- Verificar estados de error, vacío y carga en ambas plataformas.
- Confirmar que métricas financieras y reglas de deuda/pago mantienen los mismos resultados.
- Revisar documentación afectada (`SRS_app_finanzas.md`, `modulos_y_tareas_app_finanzas.md`, `README.md`).
