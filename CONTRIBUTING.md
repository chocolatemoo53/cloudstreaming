Contributing to CloudStreaming

Thank you for your interest in contributing to cloudstreaming! By participating, you’re helping to improve the project and making it better for everyone. This document provides guidelines for how to contribute.

Table of Contents

    How to Contribute

    Code Style

    Testing

    Reporting Issues

    License

How to Contribute

We welcome contributions from the community! Whether you’re fixing bugs, adding new features, or improving documentation, your help is greatly appreciated.

1. Fork the Repository

Start by forking the repository to your own GitHub account. This allows you to freely make changes without affecting the main project.

2. Create a Branch

Create a new branch for each new feature or bug fix. Try to keep each branch focused on a single purpose. This makes it easier to review and merge your changes.

git checkout -b your-branch-name

3. Make Changes

Make the necessary changes or additions to the PowerShell scripts. Follow the Code Style guidelines listed below to maintain consistency in the project.

4. Test Your Changes

Make sure your changes don’t break anything! Run any existing tests, and if applicable, add new ones to verify your changes. To test properly, you must start a new machine in the cloud and run the script from there. This ensures that your changes work in a clean environment.

5. Submit a Pull Request

Once your changes are complete, submit a pull request (PR) to the main branch. Include a clear description of the changes you made and why they’re needed.
Code Style

To keep the codebase consistent and readable, please follow these guidelines:

    Use meaningful variable and function names: Name variables and functions based on their purpose.

    Consistent indentation: Use 4 spaces per indentation level. Do not use tabs.

    Commenting: Include comments for complex or non-obvious sections of code.

    Avoid unnecessary one-liners: Keep the code easy to read; don’t squeeze multiple operations into a single line.

    Formatting: PowerShell script files should use .ps1 extensions and be UTF-8 encoded.

Example of a properly formatted function:

function Get-MyItem {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ItemName
    )

    # Fetch the item
    $item = Get-Item -Name $ItemName
    return $item
}

Formatting can be done using the built-in PowerShell formatting tools or by using an IDE that supports PowerShell formatting. For example, Visual Studio Code with the PowerShell extension can automatically format your code according to these guidelines.

Reporting Issues

If you encounter any issues with the script, please follow these steps to report them:

    Search for existing issues: Make sure the issue has not already been reported.

    Provide clear details: Include the version of PowerShell you’re using, the script or command causing the issue, and any error messages you received.

    Reproduce the issue: If possible, include steps to reproduce the issue so maintainers can quickly identify and address the problem.

If you have a solution or fix for the issue, feel free to include it in your report or submit a pull request with the fix. 

    Use the issue template: If available, use the provided issue template to ensure all necessary information is included.

It will also help if you can provide your log.txt file if applicable, as it may contain useful debugging information. 

License

By contributing to this project, you agree that your contributions will be licensed under the MIT License. This means that your contributions can be freely used, modified, and distributed by anyone, as long as they include the original license and copyright notice.

