# ========================================
# PARTE 1: CARGA Y PREPARACIÓN DE LOS DATOS
# ========================================

# --- 1. Instalar y cargar paquetes necesarios ---
packages <- c("tidyverse", "skimr", "caret", "forcats")
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(tidyverse)
library(skimr)
library(caret)
library(forcats)

# --- 2. Cargar archivo CSV ---
# Reemplaza esta ruta por la correcta en tu equipo
file_path <- "C:/Users/USER/Downloads/archive (1)/heart_attack_prediction_indonesia.csv"
data <- read_csv(file_path)

# --- 3. Revisión general del dataset ---
glimpse(data)
skim(data)
colSums(is.na(data))  # Revisar valores faltantes

# --- 4. Convertir todas las variables character a factor ---
data <- data %>%
  mutate(across(where(is.character), as.factor))

# --- 5. Convertir variables numéricas con pocos niveles a factor ---
umbral_categorica <- 10  # puedes ajustar este número si deseas
data <- data %>%
  mutate(across(
    .cols = where(~ n_distinct(.) <= umbral_categorica & !is.character(.)),
    .fns = ~ as.factor(.)
  ))

# --- 6. Convertir la variable objetivo a factor con etiquetas válidas ---
data <- data %>%
  mutate(heart_attack = factor(heart_attack, levels = c(0, 1), labels = c("No", "Yes")))

# --- 7. Verificar tipos de variables resultantes ---
str(data)

# ========================================
# PARTE 2: ANÁLISIS EXPLORATORIO DE DATOS
# ========================================

# --- 1. Histograma de variables numéricas ---
numeric_vars <- data %>%
  select(where(is.numeric))

numeric_long <- numeric_vars %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "valor")

ggplot(numeric_long, aes(x = valor)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  facet_wrap(~ variable, scales = "free", ncol = 5) +
  theme_minimal() +
  labs(title = "Distribución de variables numéricas")

# --- Definir variables categóricas y transformarlas a formato largo ---
cat_vars <- data %>%
  select(where(is.factor)) %>%
  select(-heart_attack)

cat_long <- cat_vars %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "categoria")

# --- Crear el gráfico de barras para variables categóricas ---
plot_cat_bar <- ggplot(cat_long, aes(x = categoria)) +
  geom_bar(fill = "coral", color = "black") +
  facet_wrap(~ variable, scales = "free", ncol = 4) +
  theme_minimal(base_size = 10) +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA),
    strip.background = element_rect(fill = "white", color = "black"),
    strip.text = element_text(color = "black", size = 10),
    axis.text = element_text(color = "black", size = 7),
    axis.title = element_text(color = "black"),
    plot.title = element_text(color = "black", face = "bold"),
    axis.text.x = element_text(angle = 30, hjust = 1)
  ) +
  labs(title = "Frecuencia de categorías por variable categórica",
       x = "Categoría", y = "Frecuencia")

# --- Mostrar el gráfico ---
plot_cat_bar

# --- 2. Boxplots para detección de outliers ---
ggplot(numeric_long, aes(x = variable, y = valor)) +
  geom_boxplot(fill = "lightblue") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Boxplots de variables numéricas")

# --- 3. Comparación de variables numéricas según infarto ---
data %>%
  select(where(is.numeric), heart_attack) %>%
  pivot_longer(cols = -heart_attack, names_to = "variable", values_to = "valor") %>%
  ggplot(aes(x = heart_attack, y = valor, fill = heart_attack)) +
  geom_boxplot() +
  facet_wrap(~ variable, scales = "free", ncol = 3) +
  theme_minimal() +
  labs(title = "Variables numéricas según presencia de infarto",
       x = "Infarto", y = "Valor")

# --- 4. Variables categóricas vs heart_attack ---
# Seleccionamos todas las variables factor excepto heart_attack
cat_vars <- data %>%
  select(where(is.factor)) %>%
  select(-heart_attack)


# ========================================
# INSTALACIÓN Y CARGA DE LIBRERÍAS
# ========================================

# Función para instalar si no está instalada
instalar_si_falta <- function(paquete) {
  if (!require(paquete, character.only = TRUE)) {
    install.packages(paquete, dependencies = TRUE)
    library(paquete, character.only = TRUE)
  }
}

# Lista de paquetes necesarios
paquetes <- c("caret", "xgboost", "randomForest", "ggplot2", "pROC", "dplyr")

# Instalar y cargar cada paquete
sapply(paquetes, instalar_si_falta)

# Cargar explícitamente (por claridad en el script)
library(caret)
library(xgboost)
library(randomForest)
library(ggplot2)
library(pROC)
library(dplyr)

# ========================================
# PARTE 3: PREPARACIÓN PARA ANÁLISIS PREDICTIVO (OPTIMIZADO)
# ========================================

set.seed(123)  # Reproducibilidad

# --- 1. Calcular correlaciones con heart_attack ---
data_corr <- data
data_corr$heart_attack_num <- ifelse(data_corr$heart_attack == "Yes", 1, 0)

num_vars <- data_corr %>% select(where(is.numeric))
cor_target <- cor(num_vars, use = "complete.obs", method = "spearman")[, "heart_attack_num"]

# --- 2. Seleccionar las 15 variables numéricas más correlacionadas ---
top_numeric_vars <- names(sort(abs(cor_target), decreasing = TRUE))
top_numeric_vars <- top_numeric_vars[!is.na(top_numeric_vars) & top_numeric_vars != "heart_attack_num"]
top_numeric_vars <- head(top_numeric_vars, 15)

# --- 3. Crear nuevo dataset con solo esas variables y heart_attack ---
data_model <- data %>%
  select(all_of(top_numeric_vars), heart_attack)

# --- 4. Dividir en entrenamiento y prueba (80/20) ---
index <- createDataPartition(data_model$heart_attack, p = 0.8, list = FALSE)
train_data <- data_model[index, ]
test_data  <- data_model[-index, ]

# --- 5. Escalar variables numéricas ---
scaler <- preProcess(train_data[, -ncol(train_data)], method = c("center", "scale"))

train_scaled <- predict(scaler, train_data[, -ncol(train_data)])
test_scaled  <- predict(scaler, test_data[, -ncol(test_data)])

# Volver a agregar la variable objetivo
train_final <- cbind(train_scaled, heart_attack = train_data$heart_attack)
test_final  <- cbind(test_scaled,  heart_attack = test_data$heart_attack)


# ========================================
# PARTE 4: MODELO PREDICTIVO - RANDOM FOREST
# ========================================

# Asegúrate de tener la librería cargada
library(randomForest)
library(caret)

set.seed(123)

# --- 1. Entrenar modelo Random Forest con menor cantidad de árboles (más rápido) ---
modelo_rf <- randomForest(
  heart_attack ~ ., data = train_final,
  ntree = 100,           # Número de árboles (ajustable)
  importance = TRUE
)

# --- 2. Evaluar desempeño en datos de prueba ---
pred_rf <- predict(modelo_rf, newdata = test_final)
conf_matrix_rf <- confusionMatrix(pred_rf, test_final$heart_attack)
print(conf_matrix_rf)

# --- 3. Importancia de variables ---
# Calcular importancia de variables como data.frame
importance_df <- as.data.frame(importance(modelo_rf))
importance_df$Variable <- rownames(importance_df)

# Seleccionar las 15 más importantes
top_vars <- importance_df %>%
  arrange(desc(MeanDecreaseGini)) %>%
  head(15)

# Gráfico limpio con ggplot2
library(ggplot2)

ggplot(top_vars, aes(x = reorder(Variable, MeanDecreaseGini), y = MeanDecreaseGini)) +
  geom_col(fill = "darkgreen") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Top 15 Variables Más Importantes - Random Forest",
       x = "Variable", y = "Importancia (MeanDecreaseGini)")

# --- 4. Calcular AUC y curva ROC ---
library(pROC)

probs_rf <- predict(modelo_rf, newdata = test_final, type = "prob")
roc_rf <- roc(test_final$heart_attack, probs_rf[, "Yes"])

plot(roc_rf, col = "darkgreen", lwd = 2, main = "Curva ROC - Random Forest")
auc(roc_rf)


# ========================================
# PARTE 5: MODELO PREDICTIVO - XGBOOST
# ========================================

library(xgboost)
library(pROC)


# --- 1. Convertir datos a matrices para XGBoost ---
xgb_train <- as.matrix(train_final[, -ncol(train_final)])
xgb_test  <- as.matrix(test_final[, -ncol(test_final)])

# Convertir etiquetas a 0 y 1
label_train <- ifelse(train_final$heart_attack == "Yes", 1, 0)
label_test  <- ifelse(test_final$heart_attack == "Yes", 1, 0)

# --- 2. Crear DMatrix para eficiencia ---
dtrain <- xgb.DMatrix(data = xgb_train, label = label_train)
dtest  <- xgb.DMatrix(data = xgb_test, label = label_test)

# --- 3. Entrenar el modelo ---
set.seed(123)
xgb_model <- xgboost(
  data = dtrain,
  objective = "binary:logistic",
  nrounds = 100,
  eval_metric = "auc",
  verbose = 0
)

# --- 4. Predicciones y evaluación ---
pred_probs <- predict(xgb_model, newdata = dtest)
pred_class <- ifelse(pred_probs > 0.5, 1, 0)

# Curva ROC y AUC
roc_xgb <- roc(label_test, pred_probs)
plot(roc_xgb, col = "blue", lwd = 2, main = "Curva ROC - XGBoost")
auc(roc_xgb)

# Matriz de confusión
library(caret)
confusionMatrix(factor(pred_class, levels = c(0, 1)),
                factor(label_test, levels = c(0, 1)))


# Asegúrate de tener ambas curvas ROC generadas:
# - roc_rf   (modelo_rf)
# - roc_xgb  (xgb_model)

# --- 1. Comparación gráfica ---
plot(roc_rf, col = "darkgreen", lwd = 2, main = "Comparación de Curvas ROC")
plot(roc_xgb, col = "blue", add = TRUE, lwd = 2)
abline(a = 0, b = 1, lty = 2, col = "gray")
legend("bottomright", legend = c("Random Forest", "XGBoost"),
       col = c("darkgreen", "blue"), lwd = 2)

# --- 2. Mostrar AUC de ambos modelos ---
cat("AUC Random Forest:", auc(roc_rf), "\n")
cat("AUC XGBoost:", auc(roc_xgb), "\n")

# ========================================
# PARTE 6: MODELO BASE - REGRESIÓN LOGÍSTICA
# ========================================

# Asegúrate de tener las librerías necesarias
library(caret)
library(pROC)

set.seed(123)

# --- 1. Entrenar modelo de regresión logística ---
modelo_log <- glm(
  heart_attack ~ ., data = train_final,
  family = binomial
)

# --- 2. Predecir en conjunto de prueba ---
pred_probs_log <- predict(modelo_log, newdata = test_final, type = "response")
pred_class_log <- ifelse(pred_probs_log > 0.5, "Yes", "No") %>%
  factor(levels = c("No", "Yes"))

# --- 3. Matriz de confusión ---
confusionMatrix(pred_class_log, test_final$heart_attack)

# --- 4. Curva ROC y AUC ---
roc_log <- roc(test_final$heart_attack, pred_probs_log)
plot(roc_log, col = "darkorange", lwd = 2, main = "Curva ROC - Regresión Logística")
auc(roc_log)

# Asegúrate de tener los objetos: roc_log, roc_rf, roc_xgb

# Comparación de curvas ROC
plot(roc_log, col = "darkorange", lwd = 2, main = "Comparación de Curvas ROC")
plot(roc_rf, col = "darkgreen", lwd = 2, add = TRUE)
plot(roc_xgb, col = "steelblue", lwd = 2, add = TRUE)

abline(a = 0, b = 1, lty = 2, col = "gray")

legend("bottomright",
       legend = c(
         paste0("Logística (AUC = ", round(auc(roc_log), 3), ")"),
         paste0("Random Forest (AUC = ", round(auc(roc_rf), 3), ")"),
         paste0("XGBoost (AUC = ", round(auc(roc_xgb), 3), ")")
       ),
       col = c("darkorange", "darkgreen", "steelblue"),
       lwd = 2)


# ========================================
# CORRELACIÓN ENTRE VARIABLES NUMÉRICAS E INFARTO
# ========================================

# --- 1. Convertir variable objetivo a numérica (No = 0, Yes = 1) ---
data_corr <- data
data_corr$heart_attack_num <- ifelse(data_corr$heart_attack == "Yes", 1, 0)

# --- 2. Seleccionar variables numéricas ---
num_vars <- data_corr %>%
  select(where(is.numeric))

# --- 3. Calcular correlación de Spearman con heart_attack_num ---
cor_target <- cor(num_vars, use = "complete.obs", method = "spearman")[, "heart_attack_num"]

# --- 4. Ordenar por magnitud de correlación ---
cor_target_sorted <- sort(cor_target, decreasing = TRUE)

# --- 5. Crear gráfico de correlaciones ---
library(ggplot2)

cor_df <- data.frame(
  variable = names(cor_target_sorted),
  correlacion = cor_target_sorted
) %>%
  filter(variable != "heart_attack_num")  # Excluye la variable binaria objetivo

ggplot(cor_df, aes(x = reorder(variable, correlacion), y = correlacion)) +
  geom_col(fill = "firebrick") +
  coord_flip() +
  theme_minimal(base_size = 11) +
  theme(
    panel.background = element_rect(fill = "white"),
    plot.background = element_rect(fill = "white"),
    axis.text = element_text(color = "black"),
    axis.title = element_text(color = "black"),
    plot.title = element_text(face = "bold", color = "black")
  ) +
  labs(title = "Correlación entre variables numéricas e infarto al miocardio",
       x = "Variable", y = "Correlación (Spearman)")
