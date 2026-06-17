# olist-product-analytics

Продуктовая аналитика e-commerce платформы на данных Olist (Brazilian E-Commerce). Исследование поведения пользователей, воронок, когорт, метрик доставки и качества сервиса с использованием Python и SQL.

## О проекте
Этот проект — продуктовый анализ реального e-commerce бизнеса на основе датасета Olist Brazilian E-Commerce.
Цель проекта — разобрать бизнес как продуктовый аналитик:
- понять поведение пользователей
- проанализировать воронку заказов
- оценить качество доставки
- найти точки роста продукта
- посчитать ключевые продуктовые метрики

## Данные
Используется датасет [Olist Brazilian E-Commerce Dataset (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

### Схема данных 
<img src="https://i.imgur.com/HRhd2Y0.png" width="300" height="150" align="left">


## Стек технологий
* **Язык**: Python (Pandas, NumPy, Matplotlib, Seaborn)
* **Инструменты**: Jupyter Notebook


## Структура проекта

```text
olist-ecommerce-product-analytics/
│
├── data/                  # сырые и обработанные данные
│   ├── raw
│   └── cleaned            
├── notebooks/             # Jupyter ноутбуки
│   └── 01_data_cleaning.ipynb
└── README.md
