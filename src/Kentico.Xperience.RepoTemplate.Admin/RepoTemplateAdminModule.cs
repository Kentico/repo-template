using Kentico.Xperience.Admin.Base;
using Kentico.Xperience.RepoTemplate.Admin;

[assembly: CMS.RegisterModule(typeof(RepoTemplateAdminModule))]

// Adds a new application category
[assembly: UICategory(RepoTemplateAdminModule.CUSTOM_CATEGORY, "Repo Template", Icons.CustomElement, 100)]

namespace Kentico.Xperience.RepoTemplate.Admin;

internal class RepoTemplateAdminModule : AdminModule
{
    public const string CUSTOM_CATEGORY = "Kentico.Xperience.RepoTemplate.Admin.Category";

    public RepoTemplateAdminModule()
        : base("Kentico.Xperience.RepoTemplate.Admin")
    {
    }

    protected override void OnInit()
    {
        base.OnInit();

        // Makes the module accessible to the admin UI
        // Must match AdminOrgName/ProjectName in the .csproj and orgName/projectName in Client/webpack.config.js
        RegisterClientModule("kentico", "xperience-repotemplate-admin");
    }
}
