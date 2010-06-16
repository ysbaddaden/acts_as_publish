module ActiveRecord
  module Acts #:nodoc:
    module Publish #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        # This +acts_as+ extension provides the capabilities for publishing,
        # unpublishing and prepublish objects. The class that has this
        # specified needs to have a +published+ and +published_at+ columns
        # defined as boolean and datetime respectively on the mapped database
        # table.
        # 
        # +published_at+ is defined as Time.now on create if nil.
        # 
        # It creates the following scopes:
        # 
        # - +published+
        # - +unpublished+
        # - +latest+
        def acts_as_publish()
          class_eval <<-EOV
            include ActiveRecord::Acts::Publish::InstanceMethods
            
            scope :published, Proc.new {
              where('published = ? AND published_at <= ?', true, Time.now) }
            scope :unpublished, Proc.new {
              where('published = ? OR published_at > ?', false, Time.now) }
            scope :latest, order('published_at DESC')
            
            before_create :set_publication_date
            
            private
              def set_publication_date
                self.published_at = Time.now if self.published_at.nil?
              end
          EOV
        end
        
        # Unpublishes a record.
        def unpublish(id)
          self.find(id).update_attributes(:published => false)
        end
        
        # Publishes a record. Please note that <tt>published?</tt> may still
        # declare the record as unpublished, depending on the value of
        # +:published_at+.
        def publish(id)
          self.find(id).update_attributes(:published => true)
        end
      end
      
      module InstanceMethods
        # Returns true if this record is actually published.
        def published?
          published && published_at <= Time.now
        end
        
        # Unpublishes this record.
        def unpublish
          update_attributes(:published => false)
        end
        
        # Publishes this record. Please note that <tt>published?</tt> may still
        # declare the record as unpublished, depending on the value of
        # +published_at+.
        def publish
          update_attributes(:published => true)
        end
      end
    end
  end
end
