# puppet-forge-modules-describe

This step will connect with the public Puppet Forge API and return either a list
of modules, or a single complete module object. You can pass in search queries
and parameters that match the search interface on the website, and you can specify
a list of fields to return along with the module's slug (username-modulename).

## Usage

### Getting a single module

Pass a full module name (username-modulename) as the `slug` parameter. Do not specify
any other parameters as they will be ignored. A full module object will be returned,
unless it's larger than roughly 1MB, in which case fields such as the README and task
list will be trimmed to reduce the size of the object.

See the [Forge API documentation](https://forgeapi.puppet.com/#tag/Module-Operations/operation/getModule)
for a description of the object and which fields are available to use.


### Getting a list of modules

You can pass any combination of search query and filters, just like you can on the
Forge search page. The `query` can be any string that you'd type into the search
box and the following filters should be used as follows:

* `owner`
    * A string representing a module owner. Only modules from this user will be returned.
    * Example: `puppetlabs`
* `endorsements`
    * An array/list of the endorsements you'd like to filter by. The Forge currently recognizes:
        * `supported`
        * `approved`
        * `partner`
    * Example: `[supported, approved]`
* `has_tasks`
    * Only return modules containing tasks
    * Example: `true`
* `with_pdk`
    * Only return modules built with the PDK
    * Example: `true`
* `premium`
    * Only return modules that are part of the Premium tier
    * Example: `true`
* `os`
    * Only return modules supporting this operating system.
    * Example: `redhat`
* `os_release`
    * Only return modules supporting this OS release version. Must be paired with `os`.
    * Example: `7.x` (paired with `os=redhat`)
* `os`
    * Only return modules supporting this version of Puppet.
    * Example: `7.x`
* `with_minimum_score`
    * Only return modules with at least this score. The score is normalized to a percentage, so valid values are 0-100.
    * Example: `80` (corresponds to 4+ on the search page)
* `release_within`
    * Only return modules released within the specified time period.
    * Example: `1year`

By default, the step will return a list of module slugs only. If you'd like to see
more information, specify the additional fields as an array to the `fields` parameter.
The fields available to use are any of the toplevel field from the [module object](https://forgeapi.puppet.com/#tag/Module-Operations/operation/getModule)
and any field in the `current_release`. The fields will be flattened into a single
list, rather than being nested.

Note that a lot of the data you might want to access is encapsulated in the `metadata`
field, which is a full representation of the module's `metadata.json`. This is
how you'd access information such as OS support or dependencies on other modules.

``` yaml
step:
  name: get-all-supported-modules
  image: relaysh/forge-modules-describe
  spec:
    owner: puppetlabs
    endorsements:
      - supported
    fields:
      - version
      - downloads
      - tags
      - validation_score
```
