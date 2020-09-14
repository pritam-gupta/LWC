import { LightningElement,track, wire } from 'lwc';
import mapDemo from '@salesforce/apex/UtilityClass.mapDemo';
import testName from '@salesforce/apex/UtilityClass.testName';

export default class LogicalLWCDemo extends LightningElement {
    @track greeting='Welcome Pritam Gupta';
    @track message="LWC Methodology";
    @track records;
    @track errorMessage;
    @track maps;
    @track contacts =[
        {
            Id:'239890478323',
            Name:'Test Pritam'
        },
        {
            Id:'239890478323',
            Name:'Test Pritam'
        },
        {
            Id:'239890478323',
            Name:'Test Pritam'  
        }
    ];

    /* eslint-disable no-console */
    @wire(testName) errorMessage;
      /* records({error,data}){
            if(data){
                this.records=data;
                this.errorMessage=undefined;
                console.log('>>records>data>>'+data);
            }
            if(error){
                this.records=undefined;
                this.errorMessage=error;
                console.log('>>records>error>>'+errorMessage);
            }
        }*/
    
   // console.log(records);

   handleClick(){
    mapDemo().then(result=>{
        console.log(result);
        const options=[];
        for(let key in result){
            if(key){
                options.push({
                    key:key,
                    value:result[key]
                })
            }
        }
        console.log(options);
        this.maps=options;
    })
    .catch(error=>{
        this.error=error;
    })
   }
   
}