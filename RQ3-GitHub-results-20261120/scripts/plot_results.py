"""Regenerate figures: python scripts/plot_results.py (requires matplotlib, numpy)."""
import sys, csv, json
from pathlib import Path
BASE=Path(__file__).resolve().parents[1]
DEST=BASE
PRIMARY=[s for s in json.loads((BASE/'data/protocol.json').read_text())['subjects'] if s not in ['doubleFree','CB_stringbuffer']]

def plots(summary,rows):
    sys.path.insert(0,str(BASE/'work/rq3_plot_deps'))
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np
    plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'pdf.fonttype':42})
    colors=['#2676a5','#d67b27','#4e926c']
    tools=['Period','IPB','IDB']
    lookup={(r['subject'],r['tool']):r for r in summary if r['tool']!='native'}
    def save(fig,name):
        fig.savefig(DEST/'figures'/(name+'.png'),dpi=190,bbox_inches='tight')
        fig.savefig(DEST/'figures'/(name+'.pdf'),bbox_inches='tight'); plt.close(fig)
    fig,ax=plt.subplots(figsize=(12,5.5),layout='constrained')
    x=np.arange(len(PRIMARY)); width=.24
    for i,tool in enumerate(tools):
        for j,s in enumerate(PRIMARY):
            r=lookup[s,tool]; pos=j+(i-1)*width
            if r['ok']:
                ax.bar(pos,r['slowdown_mean'],width,color=colors[i],label=tool if j==0 else None)
                ax.errorbar(pos,r['slowdown_mean'],yerr=r['slowdown_sd'] or 0,color='#222222',capsize=2,fmt='none',lw=.8)
            else: ax.text(pos,1.15,'TO',ha='center',fontsize=8,color=colors[i])
    ax.set_yscale('log'); ax.set_ylim(bottom=1)
    ax.set_xticks(x,PRIMARY,rotation=28,ha='right'); ax.set_ylabel('Invocation latency / native latency (log scale)')
    ax.set_title('RQ3: normalized invocation latency (completed searches only)')
    ax.legend(); ax.grid(axis='y',alpha=.18)
    fig.text(.01,-.045,'Mean ± sample SD across OK repeats. TO = no completed search. Separate native reference per environment; see README.',fontsize=9)
    save(fig,'rq3_overhead')
    matrix=np.array([[lookup[s,t]['ok'] for s in PRIMARY] for t in tools])
    fig,ax=plt.subplots(figsize=(12,3),layout='constrained')
    im=ax.imshow(matrix,vmin=0,vmax=10,cmap='Blues',aspect='auto')
    for i,t in enumerate(tools):
        for j,s in enumerate(PRIMARY):
            r=lookup[s,t]
            ax.text(j,i,f"{r['ok']}/10 OK\n{r['timeout']} timeout",ha='center',va='center',fontsize=8,color='white' if r['ok']>6 else '#222')
    ax.set_xticks(x,PRIMARY,rotation=28,ha='right'); ax.set_yticks(range(3),tools)
    ax.set_title('RQ3: completed searches and timeouts (9 subjects)')
    fig.colorbar(im,ax=ax,label='Completed repeats')
    save(fig,'rq3_completion')
    fig,axs=plt.subplots(2,1,figsize=(12,8),layout='constrained')
    for ax,metric,title in zip(axs,['schedules','errors'],['Completed target invocations','Invocations with target-program error']):
        for i,t in enumerate(tools):
            vals=[lookup[s,t][metric+'_mean'] if lookup[s,t]['ok'] else np.nan for s in PRIMARY]
            ax.bar(x+(i-1)*width,vals,width,color=colors[i],label=t)
        ax.set_xticks(x,PRIMARY,rotation=28,ha='right'); ax.set_ylabel('Mean per OK repeat'); ax.set_title(title)
        ax.set_yscale('symlog',linthresh=1); ax.grid(axis='y',alpha=.18)
    axs[0].legend()
    fig.text(.01,-.025,'OK searches only; missing bars are unavailable. Invocation counts include retests and repeated bounds, not unique schedules or defects.',fontsize=9)
    save(fig,'rq3_invocations_errors')

if __name__=='__main__':
    with (BASE/'data/rq3_summary.csv').open(encoding='utf-8-sig',newline='') as f:
        rows=list(csv.DictReader(f))
    for row in rows:
        for key in row:
            if key in ['subject','backend','tool','scope']: continue
            row[key]=float(row[key]) if row[key] else None
        for key in ['planned','attempted','ok','timeout','unsupported']: row[key]=int(row[key])
    plots(rows,[])
