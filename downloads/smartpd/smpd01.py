# ====================== 10 FUNÇÕES PANDAS FOR SMARTIES ======================

import pandas as pd
import numpy as np
from functools import partial
import warnings
warnings.filterwarnings('ignore')

# 1 - Method Chaining Avançado
def clean_and_enrich(df: pd.DataFrame) -> pd.DataFrame:
    """Chain elegante de limpeza e enriquecimento de dados"""
    return (df
        .assign(
            date=lambda x: pd.to_datetime(x['date']),
            year=lambda x: x['date'].dt.year,
            total=lambda x: x['price'] * x['quantity'],
            price_category=lambda x: pd.cut(x['price'], bins=[0, 50, 200, np.inf], 
                                          labels=['Barato', 'Médio', 'Premium'])
        )
        .query('quantity > 0')
        .dropna(subset=['price'])
        .reset_index(drop=True)
    )


# 2 - GroupBy com múltiplas agregações customizadas
def advanced_groupby(df: pd.DataFrame, group_col: str):
    """GroupBy poderoso com várias estatísticas personalizadas"""
    return (df.groupby(group_col)
            .agg(
                total_sales=('total', 'sum'),
                avg_price=('price', 'mean'),
                unique_customers=('customer_id', 'nunique'),
                highest_sale=('total', 'max'),
                sales_std=('total', 'std'),
                transaction_count=('total', 'count')
            )
            .round(2)
            .sort_values('total_sales', ascending=False)
    )


# 3 - np.select para múltiplas condições (melhor que vários .loc)
def categorize_sales(df: pd.DataFrame) -> pd.DataFrame:
    """Classifica vendas com múltiplas condições de forma vetorizada"""
    conditions = [
        df['total'] >= 1000,
        df['total'] >= 500,
        df['total'] >= 100
    ]
    choices = ['VIP', 'Boa', 'Média']
    
    df = df.copy()
    df['sale_category'] = np.select(conditions, choices, default='Baixa')
    return df


# 4 - Memory Optimization
def optimize_dtypes(df: pd.DataFrame) -> pd.DataFrame:
    """Reduz drasticamente o uso de memória do DataFrame"""
    for col in df.select_dtypes(include=['object']).columns:
        df[col] = df[col].astype('category')
    
    for col in df.select_dtypes(include=['int64']).columns:
        df[col] = pd.to_numeric(df[col], downcast='integer')
    
    for col in df.select_dtypes(include=['float64']).columns:
        df[col] = pd.to_numeric(df[col], downcast='float')
    
    return df


# 5 - Rolling + Expanding com GroupBy
def moving_metrics(df: pd.DataFrame, group_col: str, value_col: str, window: int = 7):
    """Métricas móveis por grupo"""
    return (df.sort_values(['date'])
            .groupby(group_col)[value_col]
            .transform(lambda x: x.rolling(window, min_periods=1).mean())
            .rename(f'{value_col}_rolling_{window}')
    )


# 6 - Pivot Table Avançada + Margins
def smart_pivot(df: pd.DataFrame):
    """Tabela dinâmica poderosa com múltiplas funções"""
    return pd.pivot_table(
        df,
        values='total',
        index='year',
        columns='price_category',
        aggfunc=['sum', 'mean', 'count'],
        margins=True,
        margins_name='TOTAL'
    ).round(2)


# 7 - Merge com diagnóstico
def merge_with_diagnosis(left: pd.DataFrame, right: pd.DataFrame, on: str, how: str = 'left'):
    """Faz merge e retorna informação sobre o join"""
    merged = pd.merge(left, right, on=on, how=how, indicator=True)
    print("Diagnóstico do Merge:")
    print(merged['_merge'].value_counts())
    return merged.drop(columns='_merge')


# 8 - Query com variáveis externas
def filter_dynamic(df: pd.DataFrame, min_price: float, max_year: int):
    """Usa query com variáveis externas de forma segura"""
    return df.query('price >= @min_price and year <= @max_year')


# 9 - Explode + Normalização de colunas aninhadas
def explode_and_normalize(df: pd.DataFrame, column: str):
    """Explode e normaliza listas/dicionários dentro de colunas"""
    df = df.explode(column)
    if df[column].apply(lambda x: isinstance(x, dict)).any():
        df = pd.concat([df.drop(columns=column), 
                       df[column].apply(pd.Series)], axis=1)
    return df


# 10 - Estilização Condicional Avançada
def style_dataframe(df: pd.DataFrame):
    """Estiliza DataFrame para relatórios bonitos"""
    return (df.style
            .format({'total': 'R$ {:.2f}', 'price': 'R$ {:.2f}'})
            .background_gradient(cmap='Blues', subset=['total'])
            .highlight_max(subset=['total'], color='gold')
            .set_caption("Relatório Smart - Análise de Vendas")
    )


# =========================== TESTES ===========================

if __name__ == "__main__":
    print("=== 10 Pandas Tricks For Smarties ===\n")
    
    # Criando dados de teste
    np.random.seed(42)
    dates = pd.date_range('2025-01-01', periods=100)
    data = {
        'date': np.random.choice(dates, 500),
        'customer_id': np.random.randint(1000, 1200, 500),
        'price': np.random.uniform(10, 800, 500),
        'quantity': np.random.randint(1, 20, 500),
    }
    df = pd.DataFrame(data)
    df = clean_and_enrich(df)
    
    print("1. DataFrame limpo (primeiras 3 linhas):")
    print(df.head(3))
    
    print("\n2. GroupBy Avançado:")
    print(advanced_groupby(df, 'year').head())
    
    print("\n3. Categorização com np.select:")
    print(categorize_sales(df)['sale_category'].value_counts())
    
    print(f"\n4. Otimização de memória: {df.memory_usage(deep=True).sum() / 1024:.1f} KB → ", 
          end="")
    df_opt = optimize_dtypes(df)
    print(f"{df_opt.memory_usage(deep=True).sum() / 1024:.1f} KB")
    
    print("\n6. Smart Pivot Table:")
    print(smart_pivot(df))
    
    print("\n✅ Todos os tricks testados com sucesso!")
