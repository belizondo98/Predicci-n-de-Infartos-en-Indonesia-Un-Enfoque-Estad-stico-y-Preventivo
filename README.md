# Predicción de Infarto en Indonesia

Este repositorio contiene el código y documentación correspondiente a una investigación para la **predicción del infarto al miocardio** utilizando el dataset "heart_attack_prediction_indonesia.csv". El análisis se desarrolló en R, abarcando desde la preparación y exploración de los datos hasta la implementación y evaluación de modelos predictivos como Random Forest, XGBoost y regresión logística.

## Contenido

- **[Descripción del Dataset](#descripción-del-dataset)**
- **[Metodología](#metodología)**
  - [Preparación y Limpieza de los Datos](#preparación-y-limpieza-de-los-datos)
  - [Análisis Exploratorio de Datos (EDA)](#análisis-exploratorio-de-datos-eda)
  - [Selección de Variables y Optimización](#selección-de-variables-y-optimización)
  - [Modelado Predictivo](#modelado-predictivo)
  - [Evaluación de Modelos](#evaluación-de-modelos)
  - [Análisis de Correlación](#análisis-de-correlación)
- **[Requisitos e Instalación](#requisitos-e-instalación)**
- **[Ejecución del Código](#ejecución-del-código)**
- **[Conclusiones](#conclusiones)**
- **[Contacto](#contacto)**
- **[Licencia](#licencia)**

## Descripción del Dataset

El dataset "heart_attack_prediction_indonesia.csv" contiene 14 columnas que recopilan información clínica de pacientes, utilizada para predecir la ocurrencia de un infarto. Se dividen en variables numéricas y categóricas:

### Columnas Numéricas
1. **age**  
   - **Tipo:** Numérica (continua)  
   - **Descripción:** Edad del paciente en años.

2. **trestbps**  
   - **Tipo:** Numérica (continua)  
   - **Descripción:** Presión arterial en reposo medida en mm Hg.

3. **chol**  
   - **Tipo:** Numérica (continua)  
   - **Descripción:** Nivel de colesterol sérico, normalmente en mg/dl.

4. **thalach**  
   - **Tipo:** Numérica (continua)  
   - **Descripción:** Frecuencia cardíaca máxima alcanzada durante una prueba de esfuerzo.

5. **oldpeak**  
   - **Tipo:** Numérica (continua)  
   - **Descripción:** Depresión del segmento ST inducida por el ejercicio, relativa al reposo.

6. **ca**  
   - **Tipo:** Numérica o categórica (según codificación)  
   - **Descripción:** Número de vasos principales coloreados por fluoroscopia, indicador de la extensión de la enfermedad coronaria.

### Columnas Categóricas
1. **sex**  
   - **Tipo:** Categórica (factor)  
   - **Descripción:** Género del paciente (por ejemplo, "Male" o "Female" o 0/1, según la codificación original).

2. **cp**  
   - **Tipo:** Categórica (factor)  
   - **Descripción:** Tipo de dolor torácico. Los valores pueden representar distintas presentaciones, como angina típica o atípica.

3. **fbs**  
   - **Tipo:** Categórica (factor)  
   - **Descripción:** Resultado del test de azúcar en ayunas, usualmente codificado como "Yes" (si el nivel es mayor a un umbral, por ejemplo, 120 mg/dl) o "No".

4. **restecg**  
   - **Tipo:** Categórica (factor)  
   - **Descripción:** Resultados del electrocardiograma en reposo. Normalmente clasificado en categorías como "normal", "anormalidad en la repolarización" o "hipertrofia ventricular".

5. **exang**  
   - **Tipo:** Categórica (factor)  
   - **Descripción:** Indica si se presenta angina inducida por el ejercicio ("Yes" o "No").

6. **slope**  
   - **Tipo:** Categórica (factor)  
   - **Descripción:** Pendiente del segmento ST durante la prueba de esfuerzo, que puede clasificarse (por ejemplo, "upsloping", "flat", "downsloping").

7. **thal**  
   - **Tipo:** Categórica (factor)  
   - **Descripción:** Resultado de la prueba de talasemia o evaluación de la perfusión miocárdica. Las categorías pueden incluir valores como "normal", "defecto fijo" o "defecto reversible".

8. **heart_attack**  
   - **Tipo:** Categórica (factor, variable objetivo)  
   - **Descripción:** Indica si el paciente ha sufrido un infarto al miocardio. Se utiliza como variable objetivo en los modelos predictivos y normalmente se codifica como "No" y "Yes".

*Nota:* Estas descripciones son tentativas y se basan en convenciones comunes. Se recomienda consultar la documentación oficial del dataset para confirmar cada descripción.

## Metodología

El proceso de la investigación se estructuró en las siguientes fases:

### Preparación y Limpieza de los Datos
- **Instalación y carga de paquetes:** Se utilizaron librerías como `tidyverse`, `skimr`, `caret` y `forcats` para la manipulación, transformación y visualización de los datos.
- **Revisión del dataset:** Se revisó la estructura y se evaluaron valores faltantes.
- **Transformación de variables:**  
  - Conversión de variables *character* a *factor*.  
  - Identificación y conversión de variables numéricas con pocos niveles (cuando representan categorías) a *factor*.  
  - Transformación de la variable `heart_attack` en un factor con etiquetas "No" y "Yes".

### Análisis Exploratorio de Datos (EDA)
- **Distribución de variables numéricas:** Se generaron histogramas y boxplots para analizar la presencia de outliers.
- **Variables categóricas:** Se crearon gráficos de barras para visualizar la frecuencia de cada categoría.
- **Comparación según la variable objetivo:** Se visualizó la diferencia en la distribución de variables numéricas y categóricas en función de la ocurrencia de infarto.

### Selección de Variables y Optimización
- **Cálculo de correlaciones:** Se calculó la correlación (método Spearman) entre las variables numéricas y la ocurrencia de infarto.
- **Selección de variables:** Se seleccionaron las 15 variables numéricas con mayor correlación para construir un dataset optimizado para el modelado.

### Modelado Predictivo
Se entrenaron tres modelos:
- **Random Forest:**  
  - Modelo entrenado con 100 árboles.  
  - Evaluación mediante matriz de confusión, importancia de variables y curva ROC (AUC).
- **XGBoost:**  
  - Preparación de los datos mediante matrices y DMatrix para optimizar el entrenamiento.  
  - Evaluación basada en AUC y matriz de confusión.
- **Regresión Logística:**  
  - Modelo de referencia para clasificación, evaluado con matriz de confusión y curva ROC.

### Evaluación de Modelos
- **Curvas ROC y AUC:** Se generaron y compararon curvas ROC para los tres modelos.
- **Importancia de Variables:** Se visualizó la importancia de las variables en el modelo Random Forest mediante gráficos de barras.

### Análisis de Correlación
- Se profundizó en la relación entre cada variable numérica y la ocurrencia de infarto, lo que permitió identificar potenciales indicadores de riesgo.

## Requisitos e Instalación

### Prerrequisitos
- R (versión 3.6 o superior recomendada).
- Conexión a Internet para instalar paquetes (si no se encuentran instalados).

### Paquetes Utilizados
El análisis utiliza los siguientes paquetes:
- `tidyverse`
- `skimr`
- `caret`
- `forcats`
- `xgboost`
- `randomForest`
- `pROC`
- `ggplot2`
- `dplyr`

El script incluye funciones que instalan y cargan estos paquetes automáticamente si es necesario.

## Ejecución del Código

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/tu_usuario/tu_repositorio.git
