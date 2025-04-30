import requests
import os
from typing import List

class CodeQLConfig:
    def __init__(self, token: str, owner: str):
        self.token = token
        self.owner = owner
        self.base_url = "https://api.github.com"
        self.headers = {
            "Authorization": f"token {token}",
            "Accept": "application/vnd.github.v3+json"
        }

    def set_codeql_languages(self, repo: str, languages: List[str]) -> bool:
        """
        Configure CodeQL analysis languages for a repository
        
        Args:
            languages: List of languages to analyze (e.g., ['javascript', 'python', 'java'])
        Returns:
            bool: True if successful, False otherwise
        """
        endpoint = f"{self.base_url}/repos/{self.owner}/{repo}/code-scanning/default-setup"

        payload = {
            "state": "configured",
            "languages": languages
        }

        try:
            response = requests.patch(
                endpoint,
                headers=self.headers,
                json=payload
            )

            if response.status_code in [200, 201, 202]:
                print(f"Successfully configured CodeQL for: {', '.join(languages)}")
                return True
            else:
                print(f"Error: {response.status_code}")
                print(response.json())
                return False

        except Exception as e:
            print(f"Error: {str(e)}")
            return False

def main():
    # Get GitHub token from environment variable
    token = os.getenv("GITHUB_TOKEN")
    if not token:
        raise ValueError("GITHUB_TOKEN environment variable not set")

    # Configure these values for your repository
    owner = ""
    repos = [""]

    # Languages to enable for CodeQL analysis
    languages_to_scan = ["actions", "python"]

    config = CodeQLConfig(token, owner)
    for repo in repos:
        config.set_codeql_languages(repo, languages_to_scan)

if __name__ == "__main__":
    main()
