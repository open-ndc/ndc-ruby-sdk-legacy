module NDCClient
  module Messages

    class AirShoppingRQ

      def initialize(params, options = nil, wrappers = nil)
        @travel_agency = options['travelAgency']
        @wrappers = wrappers

        @message = Nokogiri::XML::Builder.new {|xml|
                  xml.AirShoppingRQ {
                    xml.Document {
                      xml.MessageVersion_ "1.1.3"
                    }
                    xml.Party {
                      xml.Sender {
                        xml.TravelAgencySender {
                          xml.Name_ @travel_agency['name']
                          xml.IATA_Number_ @travel_agency['IATA_Number']
                          xml.AgencyID_ @travel_agency['agencyID']
                        }
                      }
                      xml.Participants {
                        xml.Participant {
                          xml.AggregatorParticipant( SequenceNumber: 1){
                            xml.Name_ "Flyiin"
                            xml.AggregatorID_ "Flyiin AggregatorID"
                          }
                        }
                      }
                    }
                    xml.Travelers {
                      xml.Traveler {
                        xml.AnonymousTraveler {
                          xml.PTC_ "ADT"
                        }
                      }
                    }
                    xml.CoreQuery {
                      xml.OriginDestinations {
                        xml.OriginDestination {
                          xml.Departure {
                            xml.AirportCode_ params[:departure_airport_code]
                            xml.Date_ params[:departure_date]
                          }
                          xml.Arrival {
                            xml.AirportCode_ params[:arrival_airport_code]
                          }
                        }
                      }
                    }
                    xml.Preferences {
                      xml.Preference {
                        xml.FarePreferences {
                          xml.Types {
                            xml.Type {
                              xml.Code_ 759
                            }
                          }
                        }
                      }
                    }
                    xml.Metadata {
                      xml.Other {
                        xml.OtherMetadata {
                          xml.LanguageMetadatas {
                            xml.LanguageMetadata(MetadataKey: "Display"){
                              xml.Application_ "Display"
                              xml.Code_ISO_ "en"
                            }
                          }
                        }
                      }
                    }
                  }
        }
      end

      # def doc
      #   @message.doc
      # end

      # def wrap(wrapper)
      #   @message.wrap(wrapper)
      # end

      def to_xml
        @message.doc.root.to_xml
      end

      def to_xml_with_body_wrap
        if @wrappers
          @wrappers[:open] <<
          @message.doc.root.to_xml <<
          @wrappers[:close]
        else
          @message.doc.root.to_xml
        end
      end

    end

  end
end
