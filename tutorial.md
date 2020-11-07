# devops-live-infrastructure

Sample project inspired from https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d https://github.com/gruntwork-io/terragrunt-infrastructure-live-example 
https://medium.com/@kief/https-medium-com-kief-using-pipelines-to-manage-environments-with-infrastructure-as-code-b37285a1cbf5

and used in devops education labs.

Instructions are in the MD files in labs, intended to be run from a "Google Cloudshell".

Files contains files that you can use for each step.

## Signup for Google Cloud

### Create a Google Account
First, register a new account at google with your own email https://accounts.google.com/SignUpWithoutGmail

### Create a Google Cloud  account
Go to: https://cloud.google.com/compute/docs/signup and click on "Try it free" to create a new GCE account, this will require your credit card information although you will not be billed anything.

In sweden you may need to add a "MOMS/VAT" number to be able to try it for free. You first need to find your company ORG number (10 digits), for example at allabolag.se. The vat number is SE${ORGNR}01


* [Signup](labs/signup.md)
* [Bootstrap your cloudshell and project](labs/bootStrap.md)
* [Create your first kubernetes(k8s) cluster](labs/firstK8s.md)
* [Run your first service(backend) in the cloud](labs/firstBackend.md)
