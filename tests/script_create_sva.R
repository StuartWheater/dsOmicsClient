#### Create new
library(resourcer)
library(DSLite)
library(dsBaseClient)
library(dsBase)


# make a DSLite server with resources inside
dslite.server <- newDSLiteServer(resources = list(
  GSE66351 = resourcer::newResource(name = "GSE66351", url = "https://github.com/epigeny/dsOmics/raw/master/data/GSE66351.Rdata", format = "ExpressionSet"),
  GSE80970 = resourcer::newResource(name = "GSE80970", url = "https://github.com/epigeny/dsOmics/raw/master/data/GSE80970.Rdata", format = "ExpressionSet")
))

dslite.server$assignMethods()

# build login details
builder <- DSI::newDSLoginBuilder()
builder$append(server = "study1", url = "dslite.server", resource = "GSE66351", driver = "DSLiteDriver")
builder$append(server = "study2", url = "dslite.server", resource = "GSE80970", driver = "DSLiteDriver")
logindata <- builder$build()# login and assign resources
conns <- datashield.login(logins = logindata, assign = TRUE, symbol = "res")# R data file resource


datashield.assign.expr(conns, symbol = "ES", expr = quote(as.resource.object(res)))

ds.ls(conns)
ds.dim('ES', datasources = conns)

dslite.server$assignMethod("svaDS", svaDS)

datashield.assign(conns, 'design', call("svaDS", vars=vars, eSet="ES"))


cally <- paste0("svaDS(vars=", deparse(vars), ", eSet=", eSet, ")")
datashield.assign(conns, 'design', as.symbol(cally))

datashield.assign(conns, 'design', quote(svaDS(vars=deparse(vars), eSet=ES)))

cally <- paste0("limmaDS(", mod, ",", eSets, ")")
fit <- datashield.aggregate(conns, as.symbol(cally))

calltext <- call("svaDS", vars, eSet=eSet)
datashield.assign(conns, 'design', calltext)


datashield.logout(conns)

