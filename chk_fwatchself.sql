--- [BO-FORM: {FORM-NAME:CHK_FWATCHSELF}]
--- [BO showFormLevelTriggers]  ---
/**
 * File Watcher Service - Watching for ::
 *
 *   - Action2Forms.watch
 *   - Result2Forms.watch
 *   - EOwatchSercice.watch .
 *
 */
BEGIN
   
    NULL;

END;


BEGIN
   
   Set_Custom_Property('BLK_BEANS.BEAN_WATCHER_SEND',     1, 'SetKillServer', '');
   Set_Custom_Property('BLK_BEANS.BEAN_WATCHER_RECEIVE',  1, 'SetKillServer', '');
   
   EXIT_FORM;
   
     
EXCEPTION WHEN OTHERS THEN
	prc_show('$$$ EXCEPT: '||sqlerrm);
END;
 

BEGIN
  
  NULL;

END;

BEGIN
   
   Set_Custom_Property('BLK_BEANS.BEAN_FWATCHER_SEND',    1, 'SetKillServer', '');
   Set_Custom_Property('BLK_BEANS.BEAN_FWATCHER_RECEIVE', 1, 'SetKillServer2', '');
   
   SYNCHRONIZE;
   
   EXIT_FORM;
    
EXCEPTION WHEN OTHERS THEN
 	 prc_show('$$$ EXCEPTION (KEY-EXIT): '||sqlerrm);	 
END;

--- [EO showFormLevelTriggers]  ---

--- [BO showBlockLevelTriggers] ---
--- [EO showBlockLevelTriggers] ---

--- [BO showItemLevelTriggers] ---

BEGIN
	     
  Set_Custom_Property('BLK_BEANS.BEAN_FWATCHER_SEND',      1, 'SetStartServer', 'forms'  );
  Set_Custom_Property('BLK_BEANS.BEAN_FWATCHER_RECEIVE',   1, 'SetStartServer', 'forms2' );
    
EXCEPTION WHEN OTHERS THEN
	prc_show('$$$ EXCEPTION: '||sqlerrm);
	
END;

	
BEGIN
	 -- Start LOOP : up & running . --
	 :ID_SEND    := 1;
	 :ID_RECEIVE := 1;

   Set_Custom_Property('BLK_BEANS.BEAN_FWATCHER_RECEIVE',  
       											1, 
       											'SendAction2Forms', 
       											'forms2|Action2Forms|Para1|Para2|Count='||:ID_SEND
       								);
   
    -- protocol sending --
	  prc_ins_send(:ID_SEND, 'SendAction2Forms', 'Action2Forms|Para1|Para2|Count='||:ID_SEND, 3);

EXCEPTION WHEN OTHERS THEN
	prc_show('$$$ EXCEPTION: '||sqlerrm);
END W_B_P_BT_LOOP;

BEGIN
   
   Set_Custom_Property('BLK_BEANS.BEAN_FWATCHER_SEND',     1, 'SetKillServer', '');
   Set_Custom_Property('BLK_BEANS.BEAN_FWATCHER_RECEIVE',  1, 'SetKillServer', '');
   
EXCEPTION WHEN OTHERS THEN
	prc_show('$$$ EXCEPTION: '||sqlerrm);
END;

DECLARE		
	l_event       VARCHAR2(256);
	l_currentval  VARCHAR2(128);
	l_paramType   NUMBER;
  l_BeanValList ParamList;		
BEGIN	
	l_event:= :SYSTEM.Custom_Item_Event;
	
	IF l_event='EventAction' THEN		 
	  
	   l_BeanValList := get_parameter_list(:SYSTEM.Custom_Item_Event_Parameters);
	   Get_Parameter_Attr(l_BeanValList, 'GetActionParas', l_ParamType, l_currentval);
	   
	   -- :MSG_SEND:= :MSG_SEND||chr(10)||l_event||' :: '||l_currentval||' count: '|| d2k_Delimited_String.counter(l_currentval, delimiter=>'|');
	   
	   prc_ins_send(:ID_SEND, l_event, l_currentval, d2k_Delimited_String.counter(l_currentval, delimiter=>'|'), TRUE); 

     IF substr(l_currentval, 1, 12)= 'Action2Forms' THEN 	    
        -- send back from forms only : ping-pong loop --
        :ID_SEND:= :ID_SEND+1;
        -- protocol sending --
	      prc_ins_send(:ID_SEND, 'SendAction2Forms', 'Action2Forms|Para1|Para2|Count='||:ID_SEND, 3); 
     	  -- send back from forms only : ping-pong loop --
		    Set_Custom_Property('BLK_BEANS.BEAN_FWATCHER_RECEIVE',  
		       									 1, 
		       									 'SendAction2Forms', 
		       									 'forms2|Action2Forms|Para1|Para2|Count='||:ID_SEND
		       									);    	  
     END IF;
     
	END IF;
	
	EXCEPTION WHEN OTHERS THEN 
		prc_show('$$$ EXCEPTION: '||l_event||' / '||sqlerrm);		
END W_CUST_EVNT_TRG_FWATCHER_SEND;

DECLARE	
	l_event        VARCHAR2(256);
	l_currentval   VARCHAR2(512);
	l_paramType    NUMBER;
	l_BeanValList  ParamList;	
BEGIN	
	l_event:= :SYSTEM.Custom_Item_Event;
	
	IF l_event='EventAction' THEN		 
	  
	   l_BeanValList := get_parameter_list(:SYSTEM.Custom_Item_Event_Parameters);
	   Get_Parameter_Attr(l_BeanValList, 'GetActionParas', l_ParamType, l_currentval);
	   
	   -- :MSG_RECEIVE:= :MSG_RECEIVE||chr(10)||l_event||' :: '||l_currentval||' count: '||d2k_Delimited_String.counter(l_currentval, delimiter=>'|');
	   
	   prc_ins_receive(:ID_RECEIVE, l_event, l_currentval, d2k_Delimited_String.counter(l_currentval, delimiter=>'|'), TRUE); 
	   	   
	   IF substr(l_currentval, 1, 12)= 'Action2Forms' THEN   
		    -- send back from forms only : ping-pong loop --
        :ID_RECEIVE:= :ID_RECEIVE+1;
        -- protocol: sending --	   	  
     	  prc_ins_receive(:ID_RECEIVE, 'SendAction2Forms', 'Action2Forms|Para1|Para2|Count='||:ID_RECEIVE, 3);
     	  -- send --
	      Set_Custom_Property('BLK_BEANS.BEAN_FWATCHER_SEND',  
       										   1, 
       										  'SendAction2Forms', 
       									    'forms|Action2Forms|Para1|Para2|Count='||:ID_RECEIVE
       									    );	      	
		 END IF;

	END IF;

	EXCEPTION WHEN OTHERS THEN 
		prc_show('$$$ EXCEPTION: '||l_event||' / '||sqlerrm);		
END W_CUST_EVNT_TRG_FWATCHER_RECV;

--- [EO showItemLevelTriggers] ---

--- [BO showProgrammUnits] ---
/*******************************************
   Code modified by the Forms Migration Assistant
   23-Jul-2012 01:52 PM
 *******************************************/

PROCEDURE prc_show(s VARCHAR2) IS
  b PLS_INTEGER;
BEGIN
  SET_ALERT_PROPERTY('AL_INFORMATION', ALERT_MESSAGE_TEXT,s);
  b := Show_Alert('AL_INFORMATION');
END;
PROCEDURE prc_ins_receive (p_id NUMBER, p_event VARCHAR2, p_content VARCHAR2, p_pcount NUMBER, p_marking BOOLEAN DEFAULT FALSE) IS

   l_count NUMBER(5);
   
BEGIN
	
	 go_block('BLK_RECEIVE');
	 
	 IF p_id=1 THEN
	 	 clear_block;
	 	 first_record;
	 ELSE
	 	 next_record;
	 END IF;
	 
	 :BLK_RECEIVE.ID        := p_id;
	 :BLK_RECEIVE.EVENT     := p_event;
	 :BLK_RECEIVE.CONTENT   := p_content;
	 :BLK_RECEIVE.PARACOUNT := p_pcount;
	 	 
	 l_count := d2k_Delimited_String.getNumber(
	                          d2k_Delimited_String.getString(
	                                        p_content,  
	                                        4 ), 
	                          2,  delimiter=>'=');
   
   IF p_marking THEN 
		  IF l_count <> :ID_RECEIVE THEN
		 	   -- marking as error --
		 	   Set_Item_Instance_Property('BLK_RECEIVE.EVENT', CURRENT_RECORD, VISUAL_ATTRIBUTE, 'VA_MARKED' );
		  ELSE
		 	   Set_Item_Instance_Property('BLK_RECEIVE.EVENT', CURRENT_RECORD, VISUAL_ATTRIBUTE, 'VA_NORMAL' );
		  END IF;
   END IF;
   
END;
PROCEDURE prc_ins_send (p_id NUMBER, p_event VARCHAR2, p_content VARCHAR2, p_pcount NUMBER, p_marking BOOLEAN DEFAULT FALSE) IS

   l_count NUMBER(5);
   
BEGIN
	
	 go_block('BLK_SEND');
	 
	 IF p_id=1 THEN
	 	 clear_block;
	 	 first_record;
	 ELSE
	 	 next_record;
	 END IF;
	 
	 :BLK_SEND.ID        := p_id;
	 :BLK_SEND.EVENT     := p_event;
	 :BLK_SEND.CONTENT   := p_content;
	 :BLK_SEND.PARACOUNT := p_pcount;
	 
	 l_count := d2k_Delimited_String.getNumber(
	                          d2k_Delimited_String.getString(
	                                        p_content,  
	                                        4 ), 
	                          2,  delimiter=>'=');
	 
   IF p_marking THEN 	 
		  IF l_count <> :ID_SEND+1 THEN
		 	   -- marking as error --
		 	   set_item_instance_property('BLK_SEND.EVENT', CURRENT_RECORD, VISUAL_ATTRIBUTE, 'VA_MARKED' );
		  ELSE
		 	   set_item_instance_property('BLK_SEND.EVENT', CURRENT_RECORD, VISUAL_ATTRIBUTE, 'VA_NORMAL' );
		  END IF;
   END IF;
   
END;

PROCEDURE prc_stop (p_text VARCHAR2 DEFAULT NULL) IS
BEGIN
  
  Synchronize();
  prc_show(p_text);
  
END;
--- [EO showProgrammUnits] ---

--- [EO-FORM: {FORM-NAME:CHK_FWATCHSELF}] ---

