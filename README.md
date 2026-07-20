# olist-product-analytics

SQL и Python проект по продуктовой аналитике e-commerce платформы на основе данных Olist Brazilian E-Commerce.

В проекте построены аналитические витрины данных, рассчитаны ключевые продуктовые метрики и проведен анализ пользователей, заказов, продавцов и качества доставки.

## Цель проекта

- подготовить данные для анализа;
- построить аналитическую модель данных;
- рассчитать продуктовые метрики;
- исследовать пользовательское поведение;
- получить бизнес-инсайты.

## Используемые технологии

- SQL (SQLite)
- Python (Pandas, Matplotlib)
- Jupyter Notebook
- Git / GitHub

## Структура проекта

```text
olist-ecommerce-product-analytics/
│
├── data/
│   ├── raw/                     # исходные данные
│   └── cleaned/                 # очищенные данные
│
├── sql/
│   ├── 01_data_quality.sql      # проверка качества данных
│   ├── 02_orders_enriched.sql   # обогащенная таблица заказов
│   ├── 03_customer_mart.sql     # витрина покупателей
│   ├── 04_product_mart.sql      # витрина товаров
│   ├── 05_seller_mart.sql       # витрина продавцов
│   └── 06_business_queries.sql  # расчет метрик и показателей
│
├── notebooks/
│   ├── 01_data_profiling.ipynb
│   ├── 02_data_cleaning.ipynb
│   └── 03_eda.ipynb
│
└── README.md
```


## Уже реализовано

### Подготовка данных

- проверка качества данных;
- обработка дат;
- поиск пропусков и дубликатов.

### Аналитические витрины

- **orders_enriched** — объединенная таблица заказов;
- **customer_mart** — метрики клиентов;
- **product_mart** — анализ товаров и категорий;
- **seller_mart** — анализ продавцов.

### Ключевые рассчитанные метрики

- Revenue
- GMV
- Orders
- Average Order Value (AOV)
- Customer Lifetime Value (CLV)
- Repeat Purchase Rate
- Delivery Metrics

## Дальнейшее развитие

В следующих этапах проекта планируется:

- когортный анализ;
- RFM-сегментация;
- расширенный расчет CLV;
- визуализация результатов

## Источник данных
Olist Brazilian E-Commerce Dataset: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce