import React from 'react';
import Blockies from 'react-blockies';
import Loader from './Loader';
import { Scaler } from "dapparatus";

export  default ({totalFunds, noimage, mainStyle, setLoading, loading, isLoading, buttonStyle, contracts, tx, force, emojiIndex, icon, text, selected, amount, address, dollarDisplay, balance}) => {

  let lbar = ""
  if(loading){
    lbar =  (
      <div style={{position:'absolute',left:-7,top:0,width:"100%",height:39,backgroundColor:"#DDDDDD",opacity:0.79}}>
        <div>
          <Loader noimage={noimage} loaderImage={""} mainStyle={mainStyle}/>
        </div>
      </div>
    )
  }

  let opacity = 0.65
  if(text == selected){
    opacity=0.95
  }

  if(isNaN(amount) || typeof amount == "undefined"){
    amount=0.00
    opacity=0.25
  }

  if(opacity<0.9 && parseFloat(amount)<=0.0){
    opacity=0.05
  }

  let actionButtons = ""
  if(force){
    opacity=1
    let displayText = parseFloat(text)*2
    let amountItCosts = displayText
    //console.log("text",text,"displayText",displayText,"amountItCosts",amountItCosts,"vs totalFunds ",totalFunds)

    actionButtons = (
      <div>
        <div className="content ops row"  >

          <div className="col-5">
            <button className="btn btn-large w-100" disabled={amountItCosts>totalFunds} onClick={() => {
              console.log("BUY")
              setLoading(emojiIndex,true)
              tx(
                //function buyEmoji(uint8 index)
                contracts.ERC20Vendable.buyEmoji(emojiIndex)
                ,240000,0,0,(receipt)=>{
                  if(receipt){
                    console.log("DONE WITH BUY EMOJI?")
                    setLoading(emojiIndex,false)
                  }
                }
              )
            }} style={buttonStyle.secondary}>
              <Scaler config={{startZoomAt:400,origin:"50% 50%"}}>
                <div style={{fontSize:20}}>
                  💸
                </div>
              </Scaler>
            </button>
          </div>
          <div className="col-1">
          </div>
        </div>
      </div>
    )

  }

  const handlePayment = () => {
    fetch('/api/v1/payments/0x2a65Aca4D5fC5B5C859090a6c34d164135398226/0x61C808D82A3Ac53231750daDc13c777b59310bD9').then(res => {
//       const response = JSON.parse(res.text("{\
//     \"initiator_address\": \"0xEA674fdDe714fd979de3EdF0F56AA9716B898ec8\",\
//     \"target_address\": \"0x61C808D82A3Ac53231750daDc13c777b59310bD9\",\
//     \"token_address\": \"0x2a65Aca4D5fC5B5C859090a6c34d164135398226\",\
//     \"amount\": 200,\
//     \"identifier\": 42\
// }"));


    });
  };

  return (
    <div className="balance row" style={{paddingBottom:20,textAlign:"center",maxHeight:200, paddingTop:20}}>
      <div className="avatar col p-0" style={{marginLeft: "auto", marginRight: "auto", maxWidth: 200}}>
        <img src={'/button-icons/noun_cash_2415228_000000.svg'} style={{maxWidth:50,maxHeight:50}}/>
        <div style={{left:60,top:12,fontSize:14,opacity:0.77,paddingTop:10,textAlign:'center'}}>
          $0.02 per min
        </div>
      </div>
      <div className="avatar col p-0" style={{marginLeft: "auto", marginRight: "auto", cursor: "pointer"}} onClick={handlePayment}>
        <img src={'/button-icons/DTok_logo.svg'} style={{maxWidth:100,maxHeight:100}}/>
      </div>
      <div className="avatar col p-0" style={{marginLeft: "auto", marginRight: "auto", maxWidth: 200}}>
        <img src={'/button-icons/noun_options_1063648_000000.svg'} style={{maxWidth:50,maxHeight:50}}/>
        <div style={{left:60,top:12,fontSize:14,opacity:0.77,paddingTop:10,textAlign:'center'}}>
          4 min
        </div>
      </div>
      {/*<div style={{position:"absolute",right:25,marginTop:15}}>
        <Scaler config={{startZoomAt:400,origin:"200px 30px",adjustedZoom:1}}>
          <div style={{fontSize:40,letterSpacing:-2}}>
            {dollarDisplay(amount)}
          </div>
        </Scaler>
      </div>*/}
    </div>
  )

};
