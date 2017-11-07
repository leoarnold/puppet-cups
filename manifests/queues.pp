# Private class
#
# @summary Encapsulates all private classes handling CUPS queues.
#
# This class encapsulates the indirect handling of CUPS queues
# and serves as a common container for dependecy relationships.
#
# @author Leo Arnold
# @since 2.0.0
#
class cups::queues inherits cups {

  contain cups::queues::default
  contain cups::queues::resources
  contain cups::queues::unmanaged

}
