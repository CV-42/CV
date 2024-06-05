##Predictions for sunspot numbers.

#Main findings:
- Some resources on the internet look very fancy (and may indeed teach you a lot), but hide that the result is useless.
- My own linear model was better than the random forest and the LSTM!

#Files:
- Sonnenflecke_Notebook.Rmd and Sonnenflecke_Notebook.html: My implementation.
- Präsentation.pdf: Summary, and theory. Not very beautiful layout, because of problems installing custom latex packages.

#Resources on which the implementations are based:
A: https://www.business-science.io/timeseries-analysis/2018/04/18/keras-lstm-sunspots-time-series-prediction.html
B: https://blogs.rstudio.com/ai/posts/2018-06-25-sunspots-lstm/

#Comment to nonsense on the internet:
I beleave that there is a big "nonsense" in A: It builds up a neural network with hundreds of parameters, but has only one input variable, namely the number of sunspots from exactly 50 years ago. Since there seems to be the major cycle of 50 years, it appears to yield decent predictions. But the neural network does not do anything as fancy as finding additional cycle patterns apart from this 50 years, which one can see with the eyes.... Maybe that's why B had been published a few month later. There, a whole time series is indeed fed to a neural network.

#My contribution:
In Sonneflecke_Notebook.Rmd I reimplemented parts of the post B. (Actually, there are nice techniques to learn from B!) Additionally, I implemented comparisons with a random forest prediction and a linear model.
The linear model performed best on validation sets.