import Foundation
import TSCUtility
import TuistCore
import TuistDependencies
import TuistGenerator

protocol WorkspaceMapperFactorying {
    /// Returns the default workspace mapper.
    /// - Returns: A workspace mapping instance.
    func `default`(
        tuist: Tuist
    ) -> [WorkspaceMapping]

    /// Returns a mapper for automation commands like build and test.
    /// - Parameter config: The project configuration.
    /// - Returns: A workspace mapping instance.
    func automation(
        tuist: Tuist
    ) -> [WorkspaceMapping]
}

public final class WorkspaceMapperFactory: WorkspaceMapperFactorying {
    private let projectMapper: ProjectMapping

    public init(projectMapper: ProjectMapping) {
        self.projectMapper = projectMapper
    }

    func automation(
        tuist: Tuist
    ) -> [WorkspaceMapping] {
        var mappers: [WorkspaceMapping] = []
        mappers += self.default(
            forceWorkspaceSchemes: true,
            tuist: tuist
        )

        return mappers
    }

    func `default`(
        tuist: Tuist
    ) -> [WorkspaceMapping] {
        self.default(
            forceWorkspaceSchemes: false,
            tuist: tuist
        )
    }

    public func `default`(
        forceWorkspaceSchemes: Bool,
        tuist: Tuist
    ) -> [WorkspaceMapping] {
        var mappers: [WorkspaceMapping] = []

        mappers.append(
            ProjectWorkspaceMapper(mapper: projectMapper)
        )

        mappers.append(
            TuistWorkspaceIdentifierMapper()
        )

        mappers.append(
            TuistWorkspaceRenderMarkdownReadmeMapper()
        )

        mappers.append(
            IDETemplateMacrosMapper()
        )

        mappers.append(
            AutogeneratedWorkspaceSchemeWorkspaceMapper(
                forceWorkspaceSchemes: forceWorkspaceSchemes,
                buildInsightsDisabled: tuist.project.generatedProject?.generationOptions.buildInsightsDisabled ?? true
            )
        )

        mappers.append(
            LastUpgradeVersionWorkspaceMapper()
        )

        mappers.append(ExternalDependencyPathWorkspaceMapper())

        return mappers
    }
}
