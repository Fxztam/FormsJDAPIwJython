'''
Created on 04.10.2017

@author: fmatz
'''

from oracle.forms.jdapi import FormModule, JdapiException, Jdapi;
#from pyparsing          import Word, alphas; 
 
__author__  = "Friedhold Matz"
__date__    = "01.03.2018"
__version__ = "00.03.02.20180301"

def fprint(txt):
    #file.write(txt+ "\n");
    print txt
    
def fprintcode(txt):
    file.write(txt+"\n");
    print txt
        
def showFormLevelTriggers():
    fprintcode("--- [BO showFormLevelTriggers]  ---");
    forms = fmd.getTriggers();  
    while (forms.hasNext()): 
        forms_trg =  forms.next();
        fprint(forms_trg.getName()); 
        fprintcode(forms_trg.getTriggerText());
    fprintcode("--- [EO showFormLevelTriggers]  ---\n");    


def showBlockLevelTriggers():
    fprintcode("--- [BO showBlockLevelTriggers] ---");
    blocks = fmd.getBlocks(); 
    while (blocks.hasNext()): 
        block = blocks.next();
        blk_trgs = block.getTriggers();
        while (blk_trgs.hasNext()):
            block_trg = blk_trgs.next();   
            fprint(block_trg.getName());    
            fprintcode(block_trg.getTriggerText());
    fprintcode("--- [EO showBlockLevelTriggers] ---\n");   
    
def showItemLevelTriggers():
    fprintcode("--- [BO showItemLevelTriggers] ---");
    blocks = fmd.getBlocks();
    while (blocks.hasNext()): 
        block = blocks.next();
        items = block.getItems();
        while (items.hasNext()):
            item = items.next();   
            item_trgs = item.getTriggers();
            while (item_trgs.hasNext()):
                item_trg = item_trgs.next();
                fprint(item_trg.getName());    
                fprintcode(item_trg.getTriggerText());
    fprintcode("--- [EO showItemLevelTriggers] ---\n"); 

def showProgrammUnits():
    fprintcode("--- [BO showProgrammUnits] ---");      
    progUnits = fmd.getProgramUnits();
    while (progUnits.hasNext()):
        progUnit = progUnits.next();
        fprint(progUnit.getName());
        fprintcode(progUnit.getProgramUnitText().encode('utf-8'));
    fprintcode("--- [EO showProgrammUnits] ---\n");    
    
        
if __name__ == '__main__':
    
    print("--- BO Main  ---");
    
    file = open("C:\\Work\\chk_cbox3.sql", "w");   
    FormsObj = FormModule;
        
    try:
        fmd = FormModule.openModule("C:\\Work\\chk_cbox3.fmb");
        FormsVersion = FormModule.getModulesProductVersion("C:\\Work\\chk_cbox3.fmb");   
        FormName     = fmd.getName();   
        fprint("--- Module reading OK. ---");        
    except JdapiException, ex:
        fprint(ex);
        
    fprintcode("--- [BO-FORM: {FORM-NAME:"+ FormName +"}]");
    try:
        showFormLevelTriggers();
    except JdapiException, ex:
        fprint(ex);
    
    try:
        showBlockLevelTriggers();
    except JdapiException, ex:
        fprint(ex);
    
    try:
        showItemLevelTriggers();
    except JdapiException, ex:
        fprint(ex);
    
    try:
        showProgrammUnits();
    except JdapiException, ex:
        fprint(ex);
    
    fprintcode("--- [EO-FORM: {FORM-NAME:"+ FormName +"}] ---\n");
              
    fmd.destroy();   
        
    Jdapi.shutdown();
    
    print("--- EO Main  ---"); 
    
    print "\n--------------------------------------------"
    print "-- Forms Version: \t",   FormsVersion 
    print "-- Author:        \t",    __author__  
    print "-- Program Version: \t",  __version__ 
    print "--------------------------------------------"
    
    file.close();

	