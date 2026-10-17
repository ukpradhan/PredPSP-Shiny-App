library(shiny)

required <- c("lightgbm", "Biostrings", "ftrCOOL")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Missing required R packages: ", paste(missing, collapse = ", "),
       ". Install them before running this app.")
}

library(lightgbm)
library(Biostrings)
library(ftrCOOL)

options(shiny.maxRequestSize = 20 * 1024^2)

read_fasta_text <- function(txt) {
  lines <- unlist(strsplit(txt, "\\r?\\n"))
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]
  if (!length(lines)) stop("Please paste or upload protein sequences in FASTA format.")
  if (!any(startsWith(lines, ">"))) stop("FASTA format is required: each sequence must begin with a > header.")
  headers <- which(startsWith(lines, ">"))
  if (headers[1] != 1) stop("The first non-empty line must be a FASTA header beginning with >.")
  seqs <- character(length(headers))
  ids <- character(length(headers))
  for (i in seq_along(headers)) {
    start <- headers[i] + 1
    end <- if (i < length(headers)) headers[i + 1] - 1 else length(lines)
    ids[i] <- substring(lines[headers[i]], 2)
    seqs[i] <- paste(lines[start:end][!startsWith(lines[start:end], ">")], collapse = "")
  }
  if (any(!nzchar(seqs))) stop("At least one FASTA record has an empty sequence.")
  names(seqs) <- ids
  seqs
}

predict_psp <- function(seqs, plant_type) {
  std <- strsplit("ACDEFGHIKLMNPQRSTVWY", "")[[1]]
  seqs <- toupper(gsub("\\\\s+", "", seqs))
  bad <- which(!vapply(seqs, function(s) all(strsplit(s, "")[[1]] %in% std), logical(1)))
  if (length(bad)) {
    stop("Only the 20 standard amino-acid residues (ACDEFGHIKLMNPQRSTVWY) are accepted. Invalid sequence(s): ",
         paste(names(seqs)[bad], collapse = ", "))
  }
  if (length(seqs) > 500) stop("Maximum 500 sequences per submission.")
  if (any(nchar(seqs) < 5)) stop("Each protein sequence must contain at least 5 residues.")
  # Reproduce the feature-generation procedure used by the original PredPSP scripts.
  asdc <- ftrCOOL::ASDC(seqs = unname(seqs))
  dde <- ftrCOOL::DDE(seqs = unname(seqs))
  my_dispair <- function(ss) ftrCOOL::DistancePair(seqs = ss, rng = 0, Grp = "cp20")
  dispair <- t(vapply(unname(seqs), function(s) as.numeric(my_dispair(s)), numeric(length(my_dispair(unname(seqs)[1])))))
  ksaap <- ftrCOOL::CkSAApair(seqs = unname(seqs), rng = c(0, 1, 2, 3))
  pseaac <- ftrCOOL::PSEAAC(seqs = unname(seqs), lambda = 2, w = 0.05)
  qso <- ftrCOOL::QSOrder(seqs = unname(seqs), nlag = 2, W = 0.05)
  featmat <- as.data.frame(cbind(asdc, dde, dispair, ksaap, pseaac, qso), check.names = FALSE)
  featmat[] <- lapply(featmat, function(x) as.numeric(as.character(x)))
  feature_file <- if (plant_type == "C3") "rcode/psp_c3_lightgbm_feature.txt" else "rcode/psp_c4_lightgbm_feature.txt"
  model_file <- if (plant_type == "C3") "rcode/lightgbm_c3" else "rcode/lightgbm_c4"
  nfeat <- if (plant_type == "C3") 65 else 90
  feat <- scan(feature_file, what = integer(), quiet = TRUE)[seq_len(nfeat)]
  if (max(feat) > ncol(featmat)) stop("Generated feature matrix does not match the supplied model feature indices.")
  x <- as.matrix(featmat[, feat, drop = FALSE])
  storage.mode(x) <- "double"
  booster <- lightgbm::lgb.load(model_file)
  pred <- as.numeric(predict(booster, x))
  data.frame(
    `Sequence ID` = ifelse(nzchar(names(seqs)), names(seqs), paste0("Sequence_", seq_along(seqs))),
    `Predicted probability of photosynthetic protein` = sprintf("%.4f", pred),
    `Prediction` = ifelse(pred >= 0.5, "Photosynthetic protein", "Not predicted as photosynthetic protein"),
    check.names = FALSE
  )
}

example_fasta <- paste(
  ">sp|Q20EW6|PSAA_OLTVI",
  "MTISPPEREAKKVKIVVDRNPVETSLEKWAKPGHFSRALSKGPTTTTWIWNLHADAHDFDSHTSDLEDISRKVFSAHFGQLGIIFIWLSGMYFHGARFSNYEAWLSDPTHIKV",
  ">sp|Q20EW7|PSAB_OLTVI",
  "MATKFPKFSQGLAQDPTTRRIWFGIATAHDFESHDGMTEENLYQKIFASHFGQLAIIFLWTSGNLFHVAWQGNFEQWIKDPLHIRPIAHAIWDPHFGQPAVEAFTRGGASGPV",
  sep = "\n"
)

ui <- fluidPage(
  tags$head(
    tags$title("PredPSP: Photosynthetic Protein Prediction in Plants"),
    tags$style(HTML("
      body { background:#ffffff; font-family:'Times New Roman',serif; color:#111; }
      .app-shell { max-width:1180px; margin:18px auto; border:1px solid #d7e5cf; }
      .brand { background:#E5E4E2; display:flex; align-items:center; justify-content:center; gap:22px; padding:12px 18px; }
      .brand img { width:190px; max-height:95px; object-fit:contain; }
      .brand-title { font-size:clamp(20px,2.2vw,28px); font-weight:bold; color:#0047AB; text-align:center; }
      .navbar { background:#7393B3; display:flex; flex-wrap:wrap; justify-content:center; margin:0; border:0; border-radius:0; min-height:0; }
      .navbar .nav > li > a { color:white !important; font:bold 18px 'Times New Roman',serif; padding:12px 22px; }
      .navbar .nav > li.active > a, .navbar .nav > li > a:hover { background:#52789e !important; }
      .main-content { background:#ECFFDC; padding:22px clamp(12px,3vw,36px); min-height:420px; }
      .footer { background:#E5E4E2; display:flex; align-items:center; justify-content:space-around; gap:14px; padding:10px; color:#0047AB; font-weight:bold; text-align:center; }
      .footer img { max-width:68px; max-height:75px; object-fit:contain; }
      .section-heading { font-size:22px; font-weight:bold; margin:8px 0 18px; }
      .btn-primary { background:#7393B3; border-color:#52789e; }
      .btn-primary:hover { background:#52789e; }
      .btn, .form-control { font-family:'Times New Roman',serif; font-size:16px; }
      .btn { white-space:normal; }
      .shiny-input-container { max-width:100%; }
      .results-wrap { overflow-x:auto; margin-top:18px; }
      .contact-card { text-align:center; padding:12px 6px; }
      .contact-card img { width:150px; height:150px; object-fit:cover; border-radius:4px; }
      .workflow { width:100%; height:auto; max-width:1000px; }
      @media(max-width:650px) { .brand { flex-direction:column; gap:4px; } .brand img { width:145px; } .navbar .nav > li > a { padding:9px 12px; font-size:16px; } .footer { flex-wrap:wrap; } }
    "))
  ),
  div(class="app-shell",
      div(class="brand",
          tags$img(src="images/logo_psp.png", alt="PredPSP logo"),
          div(class="brand-title", HTML("<i>Pred</i>PSP: A Web Server for Photosynthetic Protein Prediction in Plants"))
      ),
      navbarPage(
        title = NULL, id = "page", collapsible = TRUE,
        header = NULL, footer = NULL,
        tabPanel("Home", value="Home",
          div(class="main-content",
            p(style="font-size:18px; line-height:1.45; text-align:justify;",
              "Photosynthetic proteins (PSP) in plants are the architects of life on Earth. They capture the boundless energy of the sun, turning it into the chemical currency of life. The interconnected and highly specialized network of proteins involved in photosynthesis ensures the efficient utilization of this energy. This intricate dance of light and proteins not only powers plant growth but also provides oxygen and serves as a foundation for all life forms. Understanding the roles and structures of these photosynthetic proteins continues to be a vibrant area of research, offering insights into both fundamental biology and potential applications in renewable energy and agriculture. Thus, the PredPSP is developed for predicting the photosynthetic proteins in C3 and C4 plants. The light-gradient boosting method (LGBM) has been adopted for prediction, where a combination of suitable sequence-derived features was used to represent each PSP sequence as a numeric feature vector."),
            tags$img(src="images/PSP_workflow.jpeg", class="workflow", alt="PredPSP workflow", style="display:block;margin:18px auto 0;max-width:100%;height:auto;"),
            div(class="citation", style="max-width:1000px;margin:18px auto 24px;padding:0 12px;font-family:'Times New Roman',serif;font-size:16px;line-height:1.5;text-align:justify;color:#111;",
                tags$strong("Citation: "),
                "Meher, P.K., Pradhan, U.K., Sethi, P.L. et al. PredPSP: a novel computational tool to discover pathway-specific photosynthetic proteins in plants. ",
                tags$em("Plant Mol Biol"), " ", tags$strong("114"), ", 106 (2024). ",
                tags$a("https://doi.org/10.1007/s11103-024-01500-6", href="https://doi.org/10.1007/s11103-024-01500-6", target="_blank")
            )
          )
        ),
        tabPanel("Run Server", value="Run Server",
          div(class="main-content",
            h3(class="section-heading", "Photosynthetic Protein Prediction"),
            p("Choose the plant type, then paste protein sequences in FASTA format or upload a FASTA file. Maximum 500 sequences per submission."),
            radioButtons("plant_type", "Plant type", choices=c("C3"="C3","C4"="C4"), selected="C3", inline=TRUE),
            textAreaInput("fasta_text", "Paste protein sequences (FASTA)", rows=8, width="100%",
                          placeholder=">sequence_id\nMSTN..."),
            fileInput("fasta_file", "Or upload a FASTA file", accept=c(".fa",".fasta",".faa",".txt")),
            fluidRow(
              column(4, actionButton("load_example","Load example data", class="btn-primary", width="100%")),
              column(4, actionButton("clear_input","Clear text area", class="btn-default", width="100%")),
              column(4, actionButton("submit_prediction","Submit", class="btn-primary", width="100%"))
            ),
            br(),
            uiOutput("status"),
            div(class="results-wrap", tableOutput("results")),
            br(),
            downloadButton("download_results","Download results (CSV)", class="btn-primary")
          )
        ),
        tabPanel("Dataset", value="Dataset",
          div(class="main-content",
            p(style="font-size:18px; text-align:justify;",
              "For reproducible research, training and independent test datasets for both C3 and C4 plants are provided below."),
            h4("C3 plant datasets"),
            downloadButton("c3_train","Download C3 training dataset"),
            downloadButton("c3_test","Download C3 test dataset"),
            hr(),
            h4("C4 plant datasets"),
            downloadButton("c4_train","Download C4 training dataset"),
            downloadButton("c4_test","Download C4 test dataset"),
            p("The downloadable archives are included in the supplied PredPSP project.")
          )
        ),
        tabPanel("Help", value="Help",
          div(class="main-content",
            h3(class="section-heading","Input"),
            p("Supply protein sequences in FASTA format. Each sequence should contain only the 20 standard amino-acid residues: A, C, D, E, F, G, H, I, K, L, M, N, P, Q, R, S, T, V, W, Y."),
            p("Example:"),
            pre(">sp|Q20EW6|PSAA_OLTVI\nMTISPPEREAKKVKIVVDRNPVETSLEKWAKPGHFSRALSKGPTTTTWIWNLHADAHDFDSHTSDLEDISRKVFSAHFGQLGIIFIW"),
            h3(class="section-heading","Output"),
            p("The result table reports a model probability for each sequence. A probability of 1 indicates a high model score for the photosynthetic-protein class, while a value near 0 indicates a low score. The displayed class label uses a 0.5 probability threshold.")
          )
        ),
        tabPanel("Contact Us", value="Contact Us",
          div(class="main-content",
            h3(class="section-heading", style="text-align:center; color:darkgreen; text-decoration:underline;", "Project Team"),
            fluidRow(
              column(4, div(class="contact-card", tags$img(src="images/pkmeher.jpg", alt="Prabina Kumar Meher"), h4("Prabina Kumar Meher"), p("Senior Scientist"), p("Division of Statistical Genetics"), p("E-mail: ", tags$a(href="mailto:meherprabin@yahoo.com","meherprabin@yahoo.com")))),
              column(4, div(class="contact-card", tags$img(src="images/upendra.jpg", alt="Upendra Kumar Pradhan"), h4("Upendra Kumar Pradhan"), p("Senior Scientist"), p("Division of Statistical Genetics"), p("E-mail: ", tags$a(href="mailto:upendra.pradhan@icar.gov.in","upendra.iasri@icar.org.in")))),
              column(4, div(class="contact-card", tags$img(src="images/sanchita.jpg", alt="Sanchita Naha"), h4("Sanchita Naha"), p("Scientist"), p("Division of Computer Applications"), p("E-mail: ", tags$a(href="mailto:sancnaha@gmail.com","sancnaha@gmail.com"))))
            )
          )
        )
      ),
      div(class="footer",
          tags$a(href="https://icar.org.in/", target="_blank", tags$img(src="images/icarlogo.png", alt="ICAR logo")),
          span("Developed @ ICAR-IASRI, Pusa, New Delhi - 110012"),
          tags$a(href="https://iasri.icar.gov.in/", target="_blank", tags$img(src="images/iasri_logo.png", alt="ICAR-IASRI logo"))
      )
  )
)

server <- function(input, output, session) {
  rv <- reactiveValues(result=NULL, error=NULL)
  observeEvent(input$load_example, { updateTextAreaInput(session, "fasta_text", value=example_fasta) })
  observeEvent(input$clear_input, { updateTextAreaInput(session, "fasta_text", value=""); rv$result <- NULL; rv$error <- NULL })
  observeEvent(input$submit_prediction, {
    rv$result <- NULL; rv$error <- NULL
    tryCatch({
      txt <- input$fasta_text %||% ""
      if (!is.null(input$fasta_file) && nrow(input$fasta_file) > 0) {
        txt <- paste(readLines(input$fasta_file$datapath, warn=FALSE), collapse="\n")
      }
      seqs <- read_fasta_text(txt)
      rv$result <- withProgress(message="Generating sequence features and predicting...", value=0, {
        incProgress(0.1, detail="Validating FASTA")
        predict_psp(seqs, input$plant_type)
      })
    }, error=function(e) { rv$error <- conditionMessage(e) })
  })
  output$status <- renderUI({
    if (!is.null(rv$error)) div(class="alert alert-danger", rv$error)
    else if (!is.null(rv$result)) div(class="alert alert-success", paste("Prediction completed for", nrow(rv$result), "sequence(s)."))
  })
  output$results <- renderTable({ rv$result }, striped=TRUE, bordered=TRUE, hover=TRUE, spacing="s", rownames=FALSE)
  output$download_results <- downloadHandler(
    filename=function() paste0("PredPSP_results_", tolower(input$plant_type), ".csv"),
    content=function(file) { req(rv$result); write.csv(rv$result, file, row.names=FALSE, na="") }
  )
  make_dataset_download <- function(relpath) {
    downloadHandler(filename=function() basename(relpath), content=function(file) file.copy(relpath, file, overwrite=TRUE))
  }
  output$c3_train <- make_dataset_download("Dataset/c3/training/c3_train.zip")
  output$c3_test <- make_dataset_download("Dataset/c3/test/c3_test.zip")
  output$c4_train <- make_dataset_download("Dataset/c4/training/c4_train.zip")
  output$c4_test <- make_dataset_download("Dataset/c4/test/c4_test.zip")
}

shinyApp(ui, server)
