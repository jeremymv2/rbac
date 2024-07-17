DRY_RUN := --dry-run=client -o yaml

TEAM_NAMES = tiger;FinanceUsers lion;LionDept bear;MarketingGroup empteam;EmpDevelopers

define render_rbac
	while IFS=';' read -ra PAIR; do \
		sed -e "s/{{TEAM}}/$${PAIR[0]}/" team-rbac-template.yaml | \
		sed -e "s/{{GROUP}}/$${PAIR[1]}/" | \
		kubectl create \
		$(DRY_RUN) -f - > policy/$${PAIR[0]}-rbac.yaml ; \
	done <<< "$(1)" ;
endef

generate_rbac:
	@echo "Rendering manifests into /policy directory."
	@$(foreach team,$(TEAM_NAMES),$(call render_rbac,$(team)))

apply_rbac:
	@echo "Applying the RBAC policy.."
	for f in $$(ls -r policy/*yaml); do \
		echo ">> Applying $${f}" ; \
		cat $${f} | kubectl apply \
		-f - ; done

remove_rbac:
	@echo "Removing RBAC policy.."
	for f in $$(ls -r policy/*yaml); do \
		echo ">> Deleting $${f}" ; \
		cat $${f} | kubectl delete \
		-f - ; done
	rm -f policy/*yaml
