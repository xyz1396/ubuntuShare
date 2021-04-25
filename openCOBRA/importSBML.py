import cobra.test
import cobra.io
from IPython.display import display
model=cobra.io.read_sbml_model("methane.xml")
display(model)
print(model.medium)
print(model.metabolites[1])
display(model.metabolites.get_by_id("cpd00058_e0"))