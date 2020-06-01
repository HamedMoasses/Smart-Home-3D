

% network layer: for security, routing and network mangment
classdef nwk<dynamicprops
 
    
    properties
        securiyMod=[1,0,0,1]; %flag  1=RPSF    2=Authenticity,  3=Confidentiality, 4=ACL
        ACLiD=[]; % include all node list that can connect to current node
        verify=[0,0,0,0];% is used for Confirmation of security layer
        
        
    end
    
    methods
                %% security proccessing
        function security(macObj,msg)
            % ACL proccess
            if  macObj.securiyMod(4)
                if ACL(msg)
                    macObj.verify(4)=1;
                else
                    macObj.verify(4)=0;
                end
                
            else
                macObj.verify(4)=1;
            end
            
            % Confidentiality proccess
            if  macObj.securiyMod(3)
                
                if Confidentiality(msg) && macObj.verify(4)
                    macObj.verify(3)=1;
                else
                    macObj.verify(3)=0;
                end
                
            else
                macObj.verify(3)=1;
            end
            
            % Authenticity proccess
            if macObj.securiyMod(2)
                if Authenticity(msg) && macObj.verify(3)
                    macObj.verify(2)=1;
                else
                    macObj.verify(2)=0;
                end
                
                
                
            else
                macObj.verify(2)=1;
            end
            
            % RPSF proccess
            if  macObj.securiyMod(1)
                if RPSF(msg) && macObj.verify(2)
                    macObj.verify(1)=1;
                else
                    macObj.verify(1)=0;
                end
                
            else
                macObj.verify(1)=1;
            end
            
            
        end
        %% security functions
        function Confidentiality(msg)
            
            
            % Data Confidentiality or Encryption: Data is encrypted at the source and
            % decrypted at the destination using the same key; only devices with the correct
            % key can decrypt the encrypted data. Only beacon payloads, command
            % payloads and data payloads can be encrypted.
            
            
            
        end
        
        function ACL(msg)
            % Access Control: This service is as described in Section 1.16.1 for ACL mode,
            % except messages which come for unauthenticated sources are not passed up
            % to the higher layers. This feature is included in all security suites.
        end
        
        function Authenticity(msg)
            % Data Authenticity or Integrity: This service adds a Message Integrity Code
            % (MIC) to a message, which allows the detection of any tampering of the
            % message by devices without the correct encryption/decryption key.
            %
            
        end
        function RPSF(msg)
            % Replay Protection or Sequential Freshness: A frame counter is added to a
            % message, which helps a device determine how recent a received message is;
            % the appended value is compared with a value stored in the device (which is the
            % frame counter value of the last message received). This value only indicates
            % the order of messages and does not contain time/date information. This
            % protects against replay attacks in which old messages are later re-sent to a
            % device. This feature is included in all security suites of the 2006 version of the
            % IEEE 802.15.4 standard.
            
        end
        
    end
    
end

