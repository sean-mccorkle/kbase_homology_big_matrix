#uniparc  <- scan("uniparc.lens" )   # uncomment to reload. very big file
#leone_hf <- scan( "LEONE.HF.lens" )
#leone_lf <- scan( "LEONE.LF.lens")

n <- 10000
k <- n / 10

plot_len_hists <- function( lensets )
   {
    tab <- cbind( (0:k)*10 )
    for ( lens in lensets )
       {
        h <- hist( lens[lens <= n], breaks=seq(0,n,10), plot=FALSE )
        y <- c(h$counts,0)
        tab <- cbind( tab, y/sum(y) )
       }
    colors = c( "black", "blue", "darkgreen" );
    matplot( tab[,1], tab[,-1], type="l", 
             lty=1,
             col=colors,
             xlim=c(0,2000),
             xlab="length (aa)",
             ylab="normalized frequency (area=1, binsize=10)",
             main="Gene lengths" 
            )
    legend( "topright",
            legend=c("UniParc", "LEONE HF", "LEONE LF" ),
            col=colors,
            lty=1
          )

                      
 
   }

plot_len_hists( list( uniparc, leone_hf, leone_lf ) )
