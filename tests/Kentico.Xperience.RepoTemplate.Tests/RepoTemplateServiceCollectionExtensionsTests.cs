using Microsoft.Extensions.DependencyInjection;

namespace Kentico.Xperience.RepoTemplate.Tests;

public class RepoTemplateServiceCollectionExtensionsTests
{
    [Test]
    public void AddRepoTemplate_Returns_Same_ServiceCollection()
    {
        var services = new ServiceCollection();

        var result = services.AddRepoTemplate();

        Assert.That(result, Is.SameAs(services));
    }
}
