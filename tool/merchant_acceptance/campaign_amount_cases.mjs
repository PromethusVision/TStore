// Missing keys and JSON null are distinct wire inputs; both must fail when the
// selected campaign type requires that amount. Used by SQL and real HTTP proof.
export const invalidCampaignAmounts = [
  {type:'price'},
  {type:'price',price_minor:null},
  {type:'price',percentage_basis_points:1000},
  {type:'percentage'},
  {type:'percentage',percentage_basis_points:null},
  {type:'percentage',price_minor:1000},
  ...[0,-1,1000000000,1.5,'1000',true,{},[]].map(price_minor=>({type:'price',price_minor})),
  ...[0,-1,10001,1.5,'1000',true,{},[]].map(percentage_basis_points=>({type:'percentage',percentage_basis_points})),
  {type:'price',price_minor:1000,percentage_basis_points:1000},
  {type:'percentage',price_minor:1000,percentage_basis_points:1000},
  {type:'announcement',price_minor:0},
  {type:'announcement',percentage_basis_points:0},
];

export const validCampaignAmounts = [
  {type:'announcement'},
  {type:'announcement',price_minor:null,percentage_basis_points:null},
  {type:'price',price_minor:1,percentage_basis_points:null},
  {type:'price',price_minor:999999999},
  {type:'percentage',percentage_basis_points:1,price_minor:null},
  {type:'percentage',percentage_basis_points:10000},
];
